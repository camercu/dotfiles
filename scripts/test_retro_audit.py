"""Behaviour of the cross-session audit, driven through its CLI and core."""

import json
import sqlite3
import subprocess
import sys
from pathlib import Path

SCRIPT = Path(__file__).resolve().parent.parent / "common/.config/agents/skills/retro/scripts/audit.py"
sys.path.insert(0, str(SCRIPT.parent))

import audit  # noqa: E402


# --- fixture builders -------------------------------------------------------


def assistant(ts, msg_id, ctx, *blocks, model="claude-opus-5-5"):
    return {
        "type": "assistant",
        "timestamp": ts,
        "sessionId": "s1",
        "message": {
            "id": msg_id,
            "model": model,
            "content": list(blocks),
            "usage": {"input_tokens": 0, "cache_read_input_tokens": ctx},
        },
    }


def bash(call_id, command):
    return {"type": "tool_use", "id": call_id, "name": "Bash", "input": {"command": command}}


def tool(call_id, name, **inp):
    return {"type": "tool_use", "id": call_id, "name": name, "input": inp}


def result(ts, call_id, text, is_error=True):
    return {
        "type": "user",
        "timestamp": ts,
        "sessionId": "s1",
        "message": {
            "content": [
                {"type": "tool_result", "tool_use_id": call_id, "content": text, "is_error": is_error}
            ]
        },
    }


def prompt(ts, text):
    return {"type": "user", "timestamp": ts, "sessionId": "s1", "message": {"content": text}}


def write_session(root, project, name, records, sub=False):
    d = root / project / ("s1/subagents" if sub else "")
    d.mkdir(parents=True, exist_ok=True)
    path = d / f"{name}.jsonl"
    path.write_text("\n".join(json.dumps(r) for r in records) + "\n")
    return path


def run_cli(*args):
    out = subprocess.run(
        [sys.executable, str(SCRIPT), *args], capture_output=True, text=True, check=True
    )
    return json.loads(out.stdout)


# --- acceptance ---------------------------------------------------------------


def test_cli_reports_a_known_error_signature_from_a_transcript(tmp_path):
    # GIVEN a main session where BSD sed syntax fails under GNU sed
    write_session(
        tmp_path,
        "-Users-x-repos-demo",
        "s1",
        [
            prompt("2026-10-01T10:00:00Z", "fix the edition"),
            assistant("2026-10-01T10:00:01Z", "m1", 1000, bash("c1", "sed -i '' 's/a/b/' Cargo.toml")),
            result("2026-10-01T10:00:02Z", "c1", "Exit code 2\nsed: can't read s/a/b/: No such file"),
        ],
    )
    # WHEN the audit runs over that window
    report = run_cli("--projects", str(tmp_path), "--since", "2026-09-01", "--until", "2026-10-31", "--json")
    # THEN the signature is counted once, in one session
    sig = report["signatures"]["gnu-sed-bsd-syntax"]
    assert (sig["calls"], sig["sessions"], sig["projects"]) == (1, 1, 1)


# --- window -----------------------------------------------------------------


def session_with_error(ts, text, command="x", sub=False, path="p/s1.jsonl"):
    lines = [
        json.dumps(assistant(ts, "m1", 10, bash("c1", command))),
        json.dumps(result(ts, "c1", text)),
    ]
    return audit.parse_session(path, "p", sub, lines)


def test_sessions_that_ended_before_the_window_are_excluded():
    # GIVEN a session whose last record predates the window
    s = session_with_error("2026-08-01T00:00:00Z", "boom")
    # WHEN filtered to September onwards
    # THEN it is out
    assert not audit.in_window(s, "2026-09-01", "2026-09-30")


# --- signatures -------------------------------------------------------------

import pytest  # noqa: E402

SAMPLES = [
    ("worktree-rtk", "This agent is isolated in the worktree /w, but this command runs rtk with a git command among its operands"),
    ("worktree-guard", "This agent is isolated in the worktree /w, but this command is too complex to verify"),
    ("rtk-grep-regex", "Exit code 2\nrg: regex parse error:\n    (?:a|b(\n error: unclosed group"),
    ("rtk-find-unsupported", "rtk: rtk find does not support compound predicates or actions (e.g. -not, -exec)."),
    ("zsh-nomatch", "Exit code 1\n(eval):1: no matches found: --include=*.sh"),
    ("zsh-equals-expansion", "(eval):1: ===== not found"),
    ("classifier-denied", "Permission for this action was denied by the Claude Code auto mode classifier. Reason: [Git Destructive]."),
    ("classifier-no-verdict", "The server-side auto mode classifier gave no verdict (error), so auto mode cannot determine"),
    ("user-rejected", "The user doesn't want to proceed with this tool use. The tool use was rejected"),
    ("sleep-blocked", "<tool_use_error>Blocked: sleep 30 followed by: echo waited."),
    ("guard-push", 'PreToolUse:Bash hook error: ["guard-push.sh"]: guard-push: run the push as its own Bash call'),
    ("hook-blocked", 'PreToolUse:Bash hook error: ["other.sh"]: refused'),
    ("command-not-found", "Exit code 127\n(eval):1: command not found: gh"),
    ("git-bad-revision", "Exit code 128\nfatal: ambiguous argument 'a..b': unknown revision"),
    ("edit-precondition", "File has not been read yet. Read it first before writing to it."),
    ("rate-limited", "API Error: You've hit your session limit · resets 11am"),
]


@pytest.mark.parametrize("sig,text", SAMPLES, ids=[s for s, _ in SAMPLES])
def test_each_known_failure_text_maps_to_its_signature(sig, text):
    assert audit.classify(text) == sig


def test_a_failure_matching_no_signature_is_counted_as_unclassified():
    # GIVEN an error no signature knows
    s = session_with_error("2026-10-01T00:00:00Z", "<tool_use_error>a failure mode nobody has seen")
    # WHEN counted
    report = audit.build_report([s])
    # THEN it shows up rather than vanishing
    assert report["signatures"]["unclassified"]["calls"] == 1


def test_a_plain_nonzero_exit_is_kept_apart_from_unclassified_failures():
    assert audit.classify("Exit code 1\n3 tests failed") == "nonzero-exit"


# --- quota and context --------------------------------------------------------


def parse(records, sub=False, path="p/s1.jsonl"):
    return audit.parse_session(path, "p", sub, [json.dumps(r) for r in records])


def test_context_per_turn_counts_each_api_message_once():
    # GIVEN one message split over two records, then a second message
    s = parse([
        assistant("2026-10-01T00:00:00Z", "m1", 100_000),
        assistant("2026-10-01T00:00:01Z", "m1", 100_000),
        assistant("2026-10-01T00:00:02Z", "m2", 400_000),
    ])
    # WHEN measured
    q = audit.build_report([s])["quota"]
    # THEN two turns, half of them over 300k
    assert (q["main_turns"], q["main_turns_over_300k"]) == (2, 1)


def test_main_sessions_share_of_context_excludes_subagents():
    main = parse([assistant("2026-10-01T00:00:00Z", "m1", 300)])
    sub = parse([assistant("2026-10-01T00:00:00Z", "m2", 100)], sub=True, path="p/s1/subagents/a.jsonl")
    assert audit.build_report([main, sub])["quota"]["main_context_share"] == 0.75


def limit_text(day):
    return assistant(f"{day}T03:00:00Z", f"lim-{day}", 0,
                     {"type": "text", "text": "You've hit your session limit · resets 9am"}, model="<synthetic>")


def test_session_limit_hits_are_counted_per_distinct_day():
    s = parse([limit_text("2026-10-01"), limit_text("2026-10-01"), limit_text("2026-10-03")])
    assert audit.build_report([s])["quota"]["limit_hit_days"] == 2


def notification(ts, status, summary):
    # One task per notice: the task id derives from the timestamp.
    return prompt(ts, f"<task-notification>\n<task-id>t{ts}</task-id>\n<status>{status}</status>\n<summary>{summary}</summary>\n</task-notification>")


def test_background_agents_killed_by_the_rate_limit_are_counted():
    s = parse([
        notification("2026-10-01T00:00:00Z", "completed", 'Agent "Review" completed'),
        notification("2026-10-01T00:01:00Z", "failed", 'Agent "Round 3" failed: API error (error type rate_limit, HTTP 429)'),
        notification("2026-10-01T00:02:00Z", "failed", 'Agent "Spike" failed: crashed'),
    ])
    q = audit.build_report([s])["quota"]
    assert (q["agents_finished"], q["agents_failed"], q["agents_failed_rate_limit"]) == (3, 2, 1)


# --- workflow -------------------------------------------------------------------


def test_bare_continue_prompts_are_counted_but_real_requests_are_not():
    s = parse([prompt("2026-10-01T00:00:00Z", "Continue"), prompt("2026-10-01T00:01:00Z", "continue with slice 2 then push")])
    assert audit.build_report([s])["workflow"]["bare_continue_prompts"] == 1


def test_file_edits_are_split_by_method():
    # GIVEN one Edit tool call and one python heredoc rewrite
    s = parse([
        assistant("2026-10-01T00:00:00Z", "m1", 1, tool("c1", "Edit", file_path="a.rs")),
        assistant("2026-10-01T00:00:01Z", "m2", 1, bash("c2", "python3 - <<'EOF'\np.write_text(s.replace('a','b'))\nEOF")),
    ])
    # WHEN counted
    edits = audit.build_report([s])["workflow"]["edits"]
    # THEN each method has its own count
    assert (edits["tool"]["calls"], edits["shell"]["calls"]) == (1, 1)


def test_subagent_model_mix_is_a_share_of_subagent_turns():
    a = parse([assistant("2026-10-01T00:00:00Z", "m1", 1, model="claude-opus-5-5"),
               assistant("2026-10-01T00:00:01Z", "m2", 1, model="claude-opus-5-5"),
               assistant("2026-10-01T00:00:02Z", "m3", 1, model="claude-sonnet-5-5")], sub=True, path="p/s1/subagents/a.jsonl")
    assert audit.build_report([a])["workflow"]["subagent_models"] == {"claude-opus-5-5": 0.667, "claude-sonnet-5-5": 0.333}


def test_rerunning_a_command_through_an_rtk_bypass_counts_as_a_rerun():
    s = parse([
        assistant("2026-10-01T00:00:00Z", "m1", 1, bash("c1", "git log --format=%b")),
        assistant("2026-10-01T00:00:01Z", "m2", 1, bash("c2", "rtk proxy git log --format=%b")),
        assistant("2026-10-01T00:00:02Z", "m3", 1, bash("c3", "rtk proxy git status")),
    ])
    assert audit.build_report([s])["workflow"]["rtk_bypass_reruns"] == 1


# --- rtk ------------------------------------------------------------------------


def rtk_db(path, rows):
    db = sqlite3.connect(path)
    db.execute("create table commands (timestamp text, original_cmd text, rtk_cmd text, input_tokens int, output_tokens int, saved_tokens int)")
    db.executemany("insert into commands values (?,?,?,?,?,?)", rows)
    db.commit()
    db.close()


def test_rtk_savings_above_the_harness_output_cap_are_not_credited(tmp_path):
    # GIVEN a 100k-token log rtk cut to 0, which the harness would have cut to 7.5k anyway
    db = tmp_path / "h.db"
    rtk_db(db, [("2026-10-01T00:00:00Z", "cat big.log", "rtk read big.log", 100_000, 0, 100_000)])
    # WHEN summarised
    r = audit.rtk_summary(audit.read_rtk(db, "2026-09-01", "2026-10-31"))
    # THEN only the 7.5k the agent would really have seen counts as saved
    assert (r["saved_raw"], r["saved_effective"]) == (100_000, 7_500)


def test_rtk_savings_are_attributed_per_command_family(tmp_path):
    db = tmp_path / "h.db"
    rtk_db(db, [
        ("2026-10-01T00:00:00Z", "cargo nextest run", "rtk cargo nextest run", 5_000, 100, 4_900),
        ("2026-10-01T00:00:01Z", "git log", "rtk git log", 300, 300, 0),
    ])
    r = audit.rtk_summary(audit.read_rtk(db, "2026-09-01", "2026-10-31"))
    assert r["by_family"]["cargo nextest"] == 4_900


# --- WIP --------------------------------------------------------------------------


def git(repo, *args):
    subprocess.run(["git", "-C", str(repo), *args], check=True, capture_output=True)


def test_wip_counts_unpushed_commits_and_unmerged_branches(tmp_path):
    # GIVEN a clone one commit ahead of its remote, with one unmerged branch
    origin, clone = tmp_path / "origin", tmp_path / "repos" / "demo"
    git(tmp_path, "init", "-q", "-b", "main", str(origin))
    git(origin, "-c", "user.email=a@b", "-c", "user.name=a", "commit", "-q", "--allow-empty", "-m", "one")
    git(tmp_path, "clone", "-q", str(origin), str(clone))
    git(clone, "-c", "user.email=a@b", "-c", "user.name=a", "commit", "-q", "--allow-empty", "-m", "two")
    git(clone, "branch", "spike/x")
    git(clone, "checkout", "-q", "spike/x")
    git(clone, "-c", "user.email=a@b", "-c", "user.name=a", "commit", "-q", "--allow-empty", "-m", "three")
    git(clone, "checkout", "-q", "main")
    # WHEN surveyed
    wip = audit.read_wip(tmp_path / "repos")
    # THEN the repo reports its stale work
    assert wip["demo"] == {"unpushed": 1, "unmerged_branches": 1, "worktrees": 0}


# --- trend ------------------------------------------------------------------------


def test_trend_reports_change_for_each_numeric_metric():
    prev = {"quota": {"limit_hit_days": 5}, "signatures": {"zsh-nomatch": {"calls": 4}}}
    cur = {"quota": {"limit_hit_days": 2}, "signatures": {"zsh-nomatch": {"calls": 4}, "worktree-rtk": {"calls": 3}}}
    assert audit.trend(prev, cur) == {
        "quota.limit_hit_days": (5, 2),
        "signatures.worktree-rtk.calls": (None, 3),
    }


def test_cli_saves_a_snapshot_and_shows_the_change_since_the_last_one(tmp_path):
    # GIVEN a saved snapshot from an earlier run with two sed failures
    state = tmp_path / "state"
    state.mkdir()
    (state / "2026-09-30.json").write_text(json.dumps({"signatures": {"gnu-sed-bsd-syntax": {"calls": 2}}}))
    projects = tmp_path / "projects"
    write_session(projects, "-Users-x-repos-demo", "s1", [
        assistant("2026-10-01T10:00:01Z", "m1", 1, bash("c1", "sed -i '' s/a/b/ f")),
        result("2026-10-01T10:00:02Z", "c1", "sed: can't read s/a/b/: No such file"),
    ])
    # WHEN the audit runs to Markdown with that state dir
    out = subprocess.run(
        [sys.executable, str(SCRIPT), "--projects", str(projects), "--since", "2026-10-01",
         "--until", "2026-10-31", "--state", str(state), "--md"],
        capture_output=True, text=True, check=True,
    ).stdout
    # THEN the report shows the drop, and today's snapshot is saved for next time
    assert "signatures.gnu-sed-bsd-syntax.calls | 2 | 1" in out and (state / "2026-10-31.json").exists()


def test_a_bypass_rerun_that_adds_a_pipe_still_counts():
    s = parse([
        assistant("2026-10-01T00:00:00Z", "m1", 1, bash("c1", "git log --format=%b main")),
        assistant("2026-10-01T00:00:01Z", "m2", 1, bash("c2", "rtk proxy git log --format=%b main | head -50")),
    ])
    assert audit.build_report([s])["workflow"]["rtk_bypass_reruns"] == 1


def test_harness_injected_meta_records_are_not_user_prompts():
    meta = {**prompt("2026-10-01T00:00:00Z", "continue"), "isMeta": True}
    assert audit.build_report([parse([meta])])["workflow"]["bare_continue_prompts"] == 0


def test_a_session_that_started_before_the_window_but_ended_inside_it_is_included():
    s = parse([prompt("2026-08-31T23:00:00Z", "start"), prompt("2026-09-02T00:00:00Z", "end")])
    assert audit.in_window(s, "2026-09-01", "2026-09-30")


def test_repeating_a_command_without_a_bypass_is_not_a_bypass_rerun():
    s = parse([
        assistant("2026-10-01T00:00:00Z", "m1", 1, bash("c1", "cargo test")),
        assistant("2026-10-01T00:00:01Z", "m2", 1, bash("c2", "cargo test")),
    ])
    assert audit.build_report([s])["workflow"]["rtk_bypass_reruns"] == 0


def test_an_agent_the_user_killed_is_not_counted_as_failed():
    s = parse([notification("2026-10-01T00:00:00Z", "killed", 'Agent "Round 7" was stopped')])
    assert audit.build_report([s])["quota"]["agents_failed"] == 0


def test_each_signature_names_where_to_read_an_example():
    # GIVEN a failure on the second line of a transcript
    s = session_with_error("2026-10-01T00:00:00Z", "rtk: rtk find does not support compound predicates", path="p/s9.jsonl")
    # WHEN counted
    sig = audit.build_report([s])["signatures"]["rtk-find-unsupported"]
    # THEN the example points at file and line
    assert sig["examples"] == ["p/s9.jsonl:2"]


# --- review round 1 -----------------------------------------------------------


def task_note(task_id, status, summary):
    return f"<task-notification>\n<task-id>{task_id}</task-id>\n<status>{status}</status>\n<summary>{summary}</summary>\n</task-notification>"


def test_task_notifications_queued_outside_user_prompts_are_counted_once_per_task():
    # GIVEN one agent's notification delivered three ways, and a second agent queued only
    note = task_note("a1", "completed", 'Agent "Review" finished')
    s = parse([
        {"type": "queue-operation", "operation": "enqueue", "timestamp": "2026-10-01T00:00:00Z", "content": note},
        {"type": "attachment", "timestamp": "2026-10-01T00:00:00Z", "attachment": {"type": "queued_command", "prompt": note}},
        prompt("2026-10-01T00:00:01Z", note),
        {"type": "queue-operation", "operation": "enqueue", "timestamp": "2026-10-01T00:01:00Z",
         "content": task_note("a2", "failed", 'Agent "Round 2" failed: (error type rate_limit, HTTP 429)')},
    ])
    # WHEN counted
    q = audit.build_report([s])["quota"]
    # THEN two agents, one failed on the rate limit
    assert (q["agents_finished"], q["agents_failed"], q["agents_failed_rate_limit"]) == (2, 1, 1)


def test_background_shell_tasks_are_not_counted_as_agents():
    s = parse([prompt("2026-10-01T00:00:00Z", task_note("b9", "failed", 'Background command "build" failed with exit code 1'))])
    assert audit.build_report([s])["quota"]["agents_finished"] == 0


def test_a_task_that_notifies_twice_keeps_its_last_status():
    s = parse([
        prompt("2026-10-01T00:00:00Z", task_note("a1", "failed", 'Agent "R" failed: rate_limit')),
        prompt("2026-10-01T01:00:00Z", task_note("a1", "completed", 'Agent "R" finished')),
    ])
    assert audit.build_report([s])["quota"]["agents_failed"] == 0


def test_trend_reports_a_metric_that_disappeared_as_zero():
    assert audit.trend({"signatures": {"zsh-nomatch": {"calls": 9}}}, {"signatures": {}}) == {
        "signatures.zsh-nomatch.calls": (9, 0)
    }


def test_events_before_the_window_are_not_counted():
    # GIVEN a session with a failure before the window and one inside it
    s = parse([
        assistant("2026-09-20T00:00:00Z", "m1", 10, bash("c1", "sed -i '' s/a/b/ f")),
        result("2026-09-20T00:00:01Z", "c1", "sed: can't read s/a/b/: No such file"),
        assistant("2026-10-02T00:00:00Z", "m2", 10, bash("c2", "sed -i '' s/c/d/ f")),
        result("2026-10-02T00:00:01Z", "c2", "sed: can't read s/c/d/: No such file"),
    ])
    # WHEN clipped to October
    clipped = audit.clip(s, "2026-10-01", "2026-10-31")
    # THEN only the October failure counts
    assert audit.build_report([clipped])["signatures"]["gnu-sed-bsd-syntax"]["calls"] == 1


def test_limit_days_outside_the_window_are_not_counted():
    s = parse([limit_text("2026-09-25"), limit_text("2026-10-03")])
    assert audit.build_report([audit.clip(s, "2026-10-01", "2026-10-31")])["quota"]["limit_hit_days"] == 1


@pytest.mark.parametrize("sig,text", [
    ("zsh-equals-expansion", "(eval):1: =====NOLOG not found"),
    ("command-not-found", "bash: line 1: gh: command not found"),
], ids=["equals-with-suffix", "bash-format"])
def test_more_failure_text_variants_map_to_their_signature(sig, text):
    assert audit.classify(text) == sig


@pytest.mark.parametrize("text,expected", [
    ("sed: can't read src/main.rs: No such file or directory", "unclassified"),
    ("Exit code 1\n/x/guard-push.sh line 28: SC2086 double quote", "nonzero-exit"),
], ids=["sed-missing-file", "guard-push-name-in-lint"])
def test_failures_that_only_mention_a_name_do_not_match_its_signature(text, expected):
    assert audit.classify(text) == expected


def test_a_usr_bin_rerun_two_commands_later_counts_as_a_bypass_rerun():
    s = parse([
        assistant("2026-10-01T00:00:00Z", "m1", 1, bash("c1", "grep -rn 'a\\|b' src")),
        assistant("2026-10-01T00:00:01Z", "m2", 1, bash("c2", "ls src")),
        assistant("2026-10-01T00:00:02Z", "m3", 1, bash("c3", "/usr/bin/grep -rn 'a\\|b' src")),
    ])
    assert audit.build_report([s])["workflow"]["rtk_bypass_reruns"] == 1


def test_a_yes_answer_to_a_question_is_not_a_bare_continue():
    s = parse([prompt("2026-10-01T00:00:00Z", "yes")])
    assert audit.build_report([s])["workflow"]["bare_continue_prompts"] == 0


def test_rtk_filter_commands_group_by_the_filtered_tool():
    assert audit._family("rtk:toml ps aux") == "ps"


def test_synthetic_turns_are_left_out_of_the_model_mix():
    a = parse([assistant("2026-10-01T00:00:00Z", "m1", 1, model="claude-opus-5-5"),
               assistant("2026-10-01T00:00:01Z", "m2", 0, model="<synthetic>")], sub=True, path="p/s1/subagents/a.jsonl")
    assert audit.build_report([a])["workflow"]["subagent_models"] == {"claude-opus-5-5": 1.0}


def test_a_failure_with_empty_text_still_counts_as_a_failure():
    s = session_with_error("2026-10-01T00:00:00Z", "")
    assert audit.build_report([s])["signatures"]["unclassified"]["calls"] == 1


def test_show_prints_one_compact_line_per_record_around_an_example(tmp_path):
    # GIVEN a transcript whose second record is a failed result
    write_session(tmp_path, "proj", "s1", [
        assistant("2026-10-01T10:00:01Z", "m1", 1, bash("c1", "sed -i '' s/a/b/ f")),
        result("2026-10-01T10:00:02Z", "c1", "sed: can't read s/a/b/: No such file"),
        prompt("2026-10-01T10:00:03Z", "next"),
    ])
    # WHEN shown with one record of context
    out = subprocess.run([sys.executable, str(SCRIPT), "--projects", str(tmp_path), "--show", "proj/s1.jsonl:2", "--context", "1"],
                         capture_output=True, text=True, check=True).stdout.splitlines()
    # THEN three lines: the call, the marked failure, the next prompt
    assert [l.split()[0] for l in out] == ["1", ">2", "3"]


def test_turns_before_the_window_are_not_counted():
    s = parse([assistant("2026-09-20T00:00:00Z", "m1", 400_000), assistant("2026-10-02T00:00:00Z", "m2", 100)])
    assert audit.build_report([audit.clip(s, "2026-10-01", "2026-10-31")])["quota"]["main_turns"] == 1
