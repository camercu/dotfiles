#!/usr/bin/env python3
"""Cross-session audit of agent workflow waste.

Reads Claude Code transcripts (and optionally rtk's history DB and local git
repos), counts known waste signatures and workflow metrics over a date window,
and prints JSON or Markdown. Pure functions do the counting; main() does I/O.

Usage: audit.py [--projects DIR] [--since YYYY-MM-DD] [--until YYYY-MM-DD]
                [--json | --md]

Dates are UTC days, as transcripts record them; every event (call, turn,
prompt, task, limit hit) is counted only when its own timestamp is in range.
"""

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

# Each signature: id -> regex over a failed tool result's text. Order matters:
# the first match wins, so put specific signatures before general ones.
SIGNATURES = [
    ("worktree-rtk", r"isolated in the worktree.*runs rtk with"),
    ("worktree-guard", r"This agent is isolated in the worktree"),
    ("guard-push", r"\]: guard-push:"),
    ("hook-blocked", r"PreToolUse:\w+ hook (error|blocked)"),
    ("classifier-denied", r"denied by the Claude Code auto mode classifier"),
    ("classifier-no-verdict", r"auto mode classifier gave no verdict"),
    ("user-rejected", r"doesn't want to proceed"),
    ("sleep-blocked", r"Blocked: sleep"),
    ("rate-limited", r"hit your (session|usage) limit"),
    ("gnu-sed-bsd-syntax", r"sed: can't read s([/|#,@]).*\1"),
    ("rtk-grep-regex", r"rg: regex parse error"),
    ("rtk-find-unsupported", r"rtk find does not support"),
    ("zsh-nomatch", r"no matches found:"),
    ("zsh-equals-expansion", r"\(eval\):\d+: =\S* not found"),
    ("command-not-found", r"command not found\b"),
    ("git-bad-revision", r"fatal: ambiguous argument|unknown revision"),
    ("edit-precondition", r"File has not been read yet|modified since read|String to replace not found"),
    ("nonzero-exit", r"\AExit code \d+"),
]
UNCLASSIFIED = "unclassified"


@dataclass
class Call:
    name: str
    input: dict
    ts: str
    error: str | None = None
    error_line: int | None = None  # 1-based transcript line of the failed result


@dataclass
class Session:
    path: str
    project: str
    is_subagent: bool
    calls: list[Call] = field(default_factory=list)
    timestamps: list[str] = field(default_factory=list)
    turns: dict = field(default_factory=dict)  # API message id -> (context tokens, model, timestamp)
    tasks: dict = field(default_factory=dict)  # task id -> (timestamp, status, summary), last notice wins
    prompts: list = field(default_factory=list)  # (timestamp, text) typed or injected user turns
    limit_days: set = field(default_factory=set)


def clip(s, since, until):
    """The part of a session whose events fall on days since..until (inclusive)."""
    keep = lambda ts: since <= (ts or "")[:10] <= until  # noqa: E731
    return Session(
        path=s.path,
        project=s.project,
        is_subagent=s.is_subagent,
        calls=[c for c in s.calls if keep(c.ts)],
        timestamps=[t for t in s.timestamps if keep(t)],
        turns={k: v for k, v in s.turns.items() if keep(v[2])},
        prompts=[p for p in s.prompts if keep(p[0])],
        limit_days={d for d in s.limit_days if keep(d)},
        tasks={k: v for k, v in s.tasks.items() if keep(v[0])},
    )


def parse_session(path, project, is_subagent, lines):
    """Build a Session from transcript JSONL lines; skips malformed lines."""
    s = Session(path=path, project=project, is_subagent=is_subagent)
    by_id = {}
    for lineno, line in enumerate(lines, 1):
        try:
            rec = json.loads(line)
        except ValueError:
            continue
        if rec.get("timestamp"):
            s.timestamps.append(rec["timestamp"])
        msg = rec.get("message") or {}
        content = msg.get("content") if isinstance(msg, dict) else None
        if rec.get("type") == "assistant":
            _record_turn(s, rec, msg)
        _record_tasks(s, rec, content)
        if rec.get("type") == "user" and not rec.get("isMeta"):
            if isinstance(content, str):
                s.prompts.append((rec.get("timestamp", ""), content))
            elif isinstance(content, list) and not any(
                isinstance(b, dict) and b.get("type") == "tool_result" for b in content
            ):
                s.prompts.append((rec.get("timestamp", ""), _text(content)))
        if not isinstance(content, list):
            continue
        for block in content:
            if not isinstance(block, dict):
                continue
            if block.get("type") == "tool_use":
                call = Call(block.get("name", "?"), block.get("input") or {}, rec.get("timestamp", ""))
                s.calls.append(call)
                by_id[block.get("id")] = call
            elif block.get("type") == "tool_result" and block.get("is_error"):
                call = by_id.get(block.get("tool_use_id"))
                if call:
                    call.error = _text(block.get("content"))
                    call.error_line = lineno
    return s


def _record_turn(s, rec, msg):
    usage = msg.get("usage") or {}
    ctx = sum(usage.get(k) or 0 for k in ("input_tokens", "cache_read_input_tokens", "cache_creation_input_tokens"))
    s.turns.setdefault(msg.get("id"), (ctx, msg.get("model"), rec.get("timestamp", "")))
    if LIMIT_RE.search(_text(msg.get("content"))):
        s.limit_days.add(rec.get("timestamp", "")[:10])


def _record_tasks(s, rec, content):
    """Task notices arrive as queue entries, queued-command attachments, or user turns."""
    carriers = []
    if rec.get("type") == "queue-operation" and rec.get("operation") == "enqueue":
        carriers.append(rec.get("content") or "")
    attachment = rec.get("attachment")
    if isinstance(attachment, dict) and attachment.get("type") == "queued_command":
        carriers.append(str(attachment.get("prompt") or ""))
    if rec.get("type") == "user":
        carriers.append(content if isinstance(content, str) else _text(content) if isinstance(content, list) else "")
    ts = rec.get("timestamp", "")
    for text in carriers:
        for task_id, body in TASK_RE.findall(text):
            status = re.search(r"<status>(\w+)</status>", body)
            summary = re.search(r"<summary>(.*?)</summary>", body, re.S)
            if status:  # transcripts are append-ordered, so the last notice wins
                s.tasks[task_id] = (ts, status.group(1), summary.group(1) if summary else "")


LIMIT_RE = re.compile(r"hit your (session|usage) limit")
TASK_RE = re.compile(r"<task-notification>\s*<task-id>([^<]+)</task-id>(.*?)</task-notification>", re.S)


def _text(content):
    if isinstance(content, str):
        return content
    return "\n".join(b.get("text", "") for b in content or [] if isinstance(b, dict))


def classify(error_text):
    for sig, pattern in SIGNATURES:
        if re.search(pattern, error_text, re.M | re.S):
            return sig
    return UNCLASSIFIED


def in_window(session, since, until):
    return any(since <= t[:10] <= until for t in session.timestamps)


def signature_counts(sessions):
    calls, sess, projs, examples = {}, {}, {}, {}
    for s in sessions:
        for c in s.calls:
            if c.error is None:
                continue
            sig = classify(c.error)
            calls[sig] = calls.get(sig, 0) + 1
            sess.setdefault(sig, set()).add(s.path)
            projs.setdefault(sig, set()).add(s.project)
            ex = examples.setdefault(sig, [])
            if len(ex) < MAX_EXAMPLES and not any(e.startswith(s.path + ":") for e in ex):
                ex.append(f"{s.path}:{c.error_line}")
    return {
        k: {"calls": calls[k], "sessions": len(sess[k]), "projects": len(projs[k]), "examples": examples[k]}
        for k in calls
    }


MAX_EXAMPLES = 3  # one per session, so examples show spread, not one bad run


def quota(sessions):
    main = [c for s in sessions if not s.is_subagent for c, _, _ in s.turns.values() if c]
    sub = [c for s in sessions if s.is_subagent for c, _, _ in s.turns.values() if c]
    agents = {k: v for s in sessions for k, v in s.tasks.items() if v[2].startswith('Agent "')}
    failed = [summary for _, status, summary in agents.values() if status == "failed"]
    total = sum(main) + sum(sub)
    return {
        "main_turns": len(main),
        "main_turns_over_300k": sum(1 for c in main if c > 300_000),
        "main_turn_context_median": _median(main),
        "main_context_share": round(sum(main) / total, 3) if total else None,
        "subagent_turns": len(sub),
        "limit_hit_days": len(set().union(*(s.limit_days for s in sessions))),
        "agents_finished": len(agents),
        "agents_failed": len(failed),
        "agents_failed_rate_limit": sum(1 for b in failed if "rate_limit" in b or LIMIT_RE.search(b)),
    }


def _median(values):
    v = sorted(values)
    return v[len(v) // 2] if v else None


# Bare nudges only: "yes"/"ok" usually answer a question the agent rightly asked.
CONTINUE_RE = re.compile(r"\s*(continue|go on|keep going|proceed|carry on|go ahead)[.!]?\s*", re.I)
SHELL_EDIT_RE = re.compile(
    r"(^|[;&|]\s*)cat >>?[^<\n]*<<|sed -i|perl -p?i|\bsd\s|write_text\(|\.write\(", re.M
)
BYPASS_RE = re.compile(r"^\s*(rtk proxy\s+|command\s+|\\|/usr/bin/(?=\S))")
RERUN_LOOKBACK = 3  # a bypass rerun often follows one or two probing commands


def _head(cmd):
    """A command up to its first pipe or chain: bypass reruns often add `| head`."""
    return re.split(r"\s*(\||&&|;)\s*", cmd.strip(), maxsplit=1)[0]


def workflow(sessions):
    edits = {"tool": [0, 0], "shell": [0, 0]}
    reruns = 0
    models = {}
    for s in sessions:
        recent = []
        for c in s.calls:
            method = None
            if c.name in ("Edit", "Write", "NotebookEdit"):
                method = "tool"
            elif c.name == "Bash":
                cmd = c.input.get("command", "")
                if SHELL_EDIT_RE.search(cmd):
                    method = "shell"
                stripped = BYPASS_RE.sub("", cmd, count=1)
                if stripped != cmd and _head(stripped) in recent:
                    reruns += 1
                recent = (recent + [_head(cmd)])[-RERUN_LOOKBACK:]
            if method:
                edits[method][0] += 1
                edits[method][1] += c.error is not None
        if s.is_subagent:
            for _, model, _ in s.turns.values():
                if model != "<synthetic>":  # harness-written error turns, not a model choice
                    models[model] = models.get(model, 0) + 1
    total = sum(models.values())
    return {
        "bare_continue_prompts": sum(
            1 for s in sessions for _, t in s.prompts if CONTINUE_RE.fullmatch(t)
        ),
        "edits": {k: {"calls": n, "errors": e} for k, (n, e) in edits.items()},
        "rtk_bypass_reruns": reruns,
        "subagent_models": {m: round(n / total, 3) for m, n in sorted(models.items())},
    }


def build_report(sessions):
    return {
        "signatures": signature_counts(sessions),
        "quota": quota(sessions),
        "workflow": workflow(sessions),
    }


def _flatten(d, prefix=""):
    out = {}
    for k, v in d.items():
        key = f"{prefix}{k}"
        if isinstance(v, dict):
            out.update(_flatten(v, key + "."))
        elif isinstance(v, (int, float)) and not isinstance(v, bool):
            out[key] = v
    return out


def trend(previous, current):
    """Numeric metrics that changed: dotted path -> (previous or None, current or 0).

    A metric absent now reads 0: a signature a fix drove to zero drops out of
    the report, and that drop is the evidence the fix worked."""
    prev, cur = _flatten(previous), _flatten(current)
    keys = sorted(set(prev) | set(cur))
    return {k: (prev.get(k), cur.get(k, 0)) for k in keys if prev.get(k) != cur.get(k, 0)}


def render_markdown(report, changes, since, until):
    lines = [f"# Agent workflow audit {since} → {until}", ""]
    q, w = report["quota"], report["workflow"]
    lines += [
        "## Quota",
        f"- Session-limit days: {q['limit_hit_days']}",
        f"- Background agents failed: {q['agents_failed']}/{q['agents_finished']}"
        f" ({q['agents_failed_rate_limit']} rate-limited)",
        f"- Main turns over 300k context: {q['main_turns_over_300k']}/{q['main_turns']};"
        f" median {q['main_turn_context_median']}; main share {q['main_context_share']}",
        "",
        "## Workflow",
        f"- Bare continue prompts: {w['bare_continue_prompts']}",
        f"- Edits: tool {w['edits']['tool']}, shell {w['edits']['shell']}",
        f"- rtk bypass reruns: {w['rtk_bypass_reruns']}",
        f"- Subagent models: {w['subagent_models']}",
        "",
        "## Failure signatures",
        "| Signature | Calls | Sessions | Projects |",
        "|---|---|---|---|",
    ]
    for sig, c in sorted(report["signatures"].items(), key=lambda kv: -kv[1]["calls"]):
        lines.append(f"| {sig} | {c['calls']} | {c['sessions']} | {c['projects']} |")
    if "rtk" in report:
        r = report["rtk"]
        lines += ["", "## rtk", f"- Commands {r['commands']}; saved raw {r['saved_raw']},"
                  f" effective {r['saved_effective']}; median {r['saved_median']};"
                  f" top 1% share {r['top_1pct_share']}", f"- By family: {r['by_family']}"]
    if "wip" in report:
        lines += ["", "## WIP", "| Repo | Unpushed | Unmerged branches | Worktrees |", "|---|---|---|---|"]
        for repo, v in report["wip"].items():
            if v["unpushed"] or v["unmerged_branches"] or v["worktrees"]:
                lines.append(f"| {repo} | {v['unpushed']} | {v['unmerged_branches']} | {v['worktrees']} |")
    lines += ["", "## Change since last snapshot", "| Metric | Before | Now |", "|---|---|---|"]
    lines += [f"| {k} | {a} | {b} |" for k, (a, b) in changes.items()] or ["| (no snapshot) | | |"]
    return "\n".join(lines) + "\n"


# Claude Code truncates a Bash result near 30k chars (~7.5k tokens), so rtk
# saving more than that from one command saves nothing the agent would see.
HARNESS_OUTPUT_CAP_TOKENS = 7_500


def _family(rtk_cmd):
    words = rtk_cmd.split()[1:] if rtk_cmd.startswith(("rtk ", "rtk:")) else rtk_cmd.split()
    if words[:1] and words[0] in ("cargo", "git", "gh", "npm", "uv"):
        return " ".join(words[:2])
    return words[0] if words else "?"


def rtk_summary(rows):
    """rows: (rtk_cmd, input_tokens, output_tokens, saved_tokens)."""
    effective = [max(0, min(i, HARNESS_OUTPUT_CAP_TOKENS) - o) for _, i, o, _ in rows]
    by_family = {}
    for (cmd, *_), e in zip(rows, effective):
        by_family[_family(cmd)] = by_family.get(_family(cmd), 0) + e
    ranked = sorted(effective, reverse=True)
    top = ranked[: max(1, len(ranked) // 100)]
    total = sum(effective)
    return {
        "commands": len(rows),
        "saved_raw": sum(r[3] for r in rows),
        "saved_effective": total,
        "saved_median": _median(effective),
        "top_1pct_share": round(sum(top) / total, 3) if total else None,
        "by_family": dict(sorted(by_family.items(), key=lambda kv: -kv[1])[:12]),
    }


def summarize_record(rec, width=220):
    """One line for a transcript record: role, then tool calls, results, or text."""
    msg = rec.get("message") or {}
    content = msg.get("content") if isinstance(msg, dict) else None
    parts = []
    if isinstance(content, str):
        parts.append(content)
    for b in content if isinstance(content, list) else []:
        if not isinstance(b, dict):
            continue
        if b.get("type") == "tool_use":
            inp = b.get("input") or {}
            parts.append(f"{b.get('name')}: {inp.get('command') or inp.get('file_path') or json.dumps(inp)}")
        elif b.get("type") == "tool_result":
            parts.append(("ERROR " if b.get("is_error") else "result ") + _text(b.get("content")))
        elif b.get("type") == "text":
            parts.append(b.get("text", ""))
    body = " | ".join(parts) or rec.get("content") or rec.get("subtype") or ""
    return f"{rec.get('type', '?')} {' '.join(str(body).split())[:width]}"


# --- imperative shell -------------------------------------------------------


def show(projects_dir, ref, context):
    """Print records around `path:line`, marking the target line with `>`."""
    rel, _, line = ref.rpartition(":")
    target = int(line)
    with (Path(projects_dir) / rel).open(errors="replace") as f:
        for n, raw in enumerate(f, 1):
            if target - context <= n <= target + context:
                try:
                    text = summarize_record(json.loads(raw))
                except ValueError:
                    text = "(malformed line)"
                print(f"{'>' if n == target else ''}{n} {text}")
            elif n > target + context:
                break


def read_rtk(db_path, since, until):
    import sqlite3

    db = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    try:
        return db.execute(
            "select rtk_cmd, input_tokens, output_tokens, saved_tokens from commands"
            " where substr(timestamp, 1, 10) between ? and ?",
            (since, until),
        ).fetchall()
    finally:
        db.close()


def _git(repo, *args):
    import subprocess

    out = subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True)
    return out.stdout if out.returncode == 0 else None


def read_wip(repos_dir):
    """Per repo under repos_dir: unpushed main commits, unmerged branches, extra worktrees."""
    wip = {}
    for repo in sorted(Path(repos_dir).iterdir()):
        if not (repo / ".git").exists():
            continue
        unpushed = _git(repo, "rev-list", "--count", "@{u}..HEAD")  # None: no upstream
        unmerged = _git(repo, "branch", "--no-merged", "HEAD", "--format=%(refname:short)") or ""
        trees = _git(repo, "worktree", "list", "--porcelain") or ""
        wip[repo.name] = {
            "unpushed": int(unpushed) if unpushed else None,
            "unmerged_branches": len(unmerged.split()),
            "worktrees": max(0, trees.count("\nworktree ") + trees.startswith("worktree ") - 1),
        }
    return wip



def load_sessions(projects_dir):
    root = Path(projects_dir)
    for path in sorted(root.glob("**/*.jsonl")):
        rel = path.relative_to(root)
        with path.open(errors="replace") as f:
            yield parse_session(str(rel), rel.parts[0], "subagents" in rel.parts, f)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--projects", default=str(Path.home() / ".claude" / "projects"))
    ap.add_argument("--since", default="0000-00-00")
    ap.add_argument("--until", default="9999-99-99")
    ap.add_argument("--rtk-db", help="rtk history.db; omit to skip rtk metrics")
    ap.add_argument("--repos", help="directory of git repos to survey for WIP")
    ap.add_argument("--state", help="snapshot dir: compare with the latest earlier snapshot, then save this one")
    ap.add_argument("--show", metavar="PATH:LINE", help="print transcript records around an example, then exit")
    ap.add_argument("--context", type=int, default=15, help="records either side for --show")
    fmt = ap.add_mutually_exclusive_group()
    fmt.add_argument("--json", action="store_true")
    fmt.add_argument("--md", action="store_true")
    args = ap.parse_args(argv)
    if args.show:
        show(args.projects, args.show, args.context)
        return
    sessions = [clip(s, args.since, args.until) for s in load_sessions(args.projects)]
    sessions = [s for s in sessions if s.timestamps]
    report = build_report(sessions)
    if args.rtk_db:
        report["rtk"] = rtk_summary(read_rtk(args.rtk_db, args.since, args.until))
    if args.repos:
        report["wip"] = read_wip(args.repos)
    changes = {}
    if args.state:
        state = Path(args.state)
        state.mkdir(parents=True, exist_ok=True)
        name = f"{args.until}.json"
        earlier = sorted(p for p in state.glob("*.json") if p.name < name)
        if earlier:
            changes = trend(json.loads(earlier[-1].read_text()), report)
        (state / name).write_text(json.dumps(report, indent=2, sort_keys=True))
    if args.md:
        sys.stdout.write(render_markdown(report, changes, args.since, args.until))
    else:
        json.dump(report, sys.stdout, indent=2, sort_keys=True)
        print()


if __name__ == "__main__":
    main()
