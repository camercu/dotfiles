# Global agent instructions

## Writing

| Text | Register | Skill |
|---|---|---|
| Chat to user | caveman full | — |
| Agent-read: AGENTS.md, CLAUDE.md, memory, skills, subagent prompts, briefs | caveman full | `writing-for-agents` |
| Commits, PRs, issues, review comments, code comments | caveman lite | `unslop` incl. `technical.md`, no soul |
| Other public text for user: docs, emails, posts | plain | `unslop` |

@caveman.md

- Use terms from `CONTEXT.md` when present.
- Question, gate, or fork for user: ask in chat, not a tool. Numbered options, own
  recommendation, reasons. Give enough context (real code, exact API) so user
  decides without reading history or diffs. Then wait.

## Engineering values

@maintenance-first.md

Give concurrent workers separate writable files, keys, worktrees, or state
directories where possible. Assign one owner to aggregate the results. When
shared mutation is intrinsic, enforce synchronization in the design.

## Defect prevention

Bug found or mistake repeats: fix the class. Use highest tier that reaches:

1. **Make it impossible.** Types, data structures, architecture. Bad state
   unrepresentable; wrong call won't compile.
2. **Make it fail by itself.** Test, lint, CI gate, exhaustive match. Fails on
   real mistake. Runs code, not reads it.
3. **Prose.** Docs, comments, memory. Advisory; for recurring mistake, only
   beside tier 1 or 2.

Design smells: comment says "remember to" / "callers must"; fix is "be careful
next time".

Before writing test that scans source/config text, or doc that mirrors code:
read `~/.config/agents/guard-ladders.md`.

## Development process

Route by the highest-risk behavior affected. A three-line ownership change
can be high risk. Record the tier and the behavior that determines it.

| Tier | Examples | Default |
|---|---|---|
| Low | Docs, cosmetic edits, isolated mechanical or minor config changes | Relevant checks and one focused review. Mutation testing only if required by the project. |
| Medium | Ordinary features and contained refactors | `/tdd` for behavior changes, relevant integration checks and one focused review. Seek independent review for cross-module uncertainty. Target mutation testing at risky logic or suspected weak assertions. |
| High | Unsafe/FFI, concurrency, privilege, rollback or resource ownership, public safety contracts, consequential platform differences, release automation | `/tdd` for behavior changes, boundary experiments before implementation, full applicable matrix, targeted mutation or fault probes, independent review, and unresolved-risk accounting. |

Use `/harden` for high-risk changes, when requested, or when findings need
multiple passes. Reuse review evidence for the same range. For independent
review, use a fresh reviewer or human reviewer. If unavailable, record the
missing review and keep high-risk convergence unverified.

Use named skills through the harness where available, or read the installed
`SKILL.md` and apply its instructions directly. For code review, resolve
  `code-review` in the session skill list if available. Apply the Review
  brief in `~/.config/agents/skills/harden/references/pass-brief.md` either way.

Carry prior approval through implementation. Ask for consequential new
decisions, conflicting requirements, public contract changes, or destructive
actions. Follow the Git rule for pushes.

Rust library public API: follow
https://rust-lang.github.io/api-guidelines/checklist.html

## Dev environment

Repo has nix env (`shell.nix`/`flake.nix` + `.envrc`): run every repo tool
inside it (`nix-shell --run '<cmd>'` or direnv shell). Why: host, nix, CI
versions drift; host tool gives stale snapshots, CI-only failures.

Tool missing on host or in repo env (`gh`, `shellcheck`, `jq`, …): run it via
`nix-shell -p <pkg> --run '<cmd>'`, any directory, any repo. "Command not
found" is never "tool unavailable": try nix first, report only if that fails.
Subagent briefs carry this line; subagents do not read this file.

zsh: separator `---`; test `[ x = y ]`. (`==` triggers `=cmd` expansion:
`(eval):1: == not found`.) Absolute paths; cwd drifts after `cd`.

### Authoritative verification

Use the project's gate from CI or the task runner in its required environment.
For a flake with a dev shell, use `nix develop --command <cmd>` or its direnv
shell. Run the original command without output wrappers that change its status.
Save both streams to a log under `.scratch/` and record the command, tested
revision, and actual exit status. Capture status before reading or filtering
the log. Example inside the required environment:

```sh
mkdir -p .scratch
check_rc=0
env -u RTK_CARGO just ci >.scratch/ci.log 2>&1 || check_rc=$?
printf 'ci exit: %s\n' "$check_rc"
exit "$check_rc"
```

When a required check skips or its tool cannot run, report it as unverified
with the reason. A passing summary cannot override a failed command.

## Working files

Repo-local working state → `<repo>/.scratch/<skill>/`: handoffs, spike
worktrees, ledgers, review and dogfood reports, throwaway consumers. Global
git ignore covers `.scratch/` (jj honors it too); no per-repo ignore step.
Never use other top-level dirs (`.harden/` etc.). Why: survives reboot and
`/tmp` reapers; one ignored root, no per-repo setup. No repo → OS temp dir.

## Guardrails

Machine-enforceable rule (confirm, ban, workflow gate): encode in settings.json
permissions/hooks first (`update-config` skill), prose second. Prose alone
failed: push-without-ask happened with prose rule in place.

## Git

Trunk-based. These rules = whole git workflow.

- Commit direct to `main`. Every commit builds, passes tests, releasable.
- One logical change = one commit, made when green. Each review finding = own
  commit.
- Incomplete work: branch by abstraction, or hide behind flag/config/keystone
  interface. Short-lived branch (<1 day) only for too-risky change or user asks
  PR; merge fast, delete.
- Message: `conventional-commits` skill.
- Push = outward-facing: confirm first unless user said proceed. Shared trunk:
  fast-forward only; never force-push or delete it. `guard-push` hook fetches +
  rebases.
- Native Git's configured `protect-trunk` pre-push hook checks the actual
  destination and ancestry for `main`, `master`, and `trunk`. Verify
  registration with `git hook list pre-push`. Require remote branch protection
  against rewrites and deletion for clients that bypass Git hooks, including jj.

@RTK.md
