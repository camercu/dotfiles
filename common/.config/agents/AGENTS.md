# Global agent instructions

## Writing

- To user: `/caveman` skill. Use terms from `CONTEXT.md` when present.
- Question, gate, or fork for user: chat prose. Numbered options, own
  recommendation, reasons. Give enough context (real code, exact API) so user
  decides without reading history or diffs. Then wait.
- Public text for user (docs, comments, PRs, commits): `/unslop` skill.
- Agent-context files (AGENTS.md, CLAUDE.md, memory, skills): caveman style.
  - Specialist detail in own file. Pointer says when to read it.
  - Point to source of truth, with regex or line number. Summarize only when
    summary saves much context.
  - State target behavior. Prohibition only for hard guardrail with no
    positive form; pair it with target.

## Engineering values

@maintenance-first.md

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

- Behavior change: `/tdd`. Every change, refactor too: then `/harden`. Fix
  incidental issues found on the way.
- Named skill = real Skill tool call. Cannot run: report SKIPPED + reason.
- Fresh agent reviews own work.
- Rust library public API: follow
  https://rust-lang.github.io/api-guidelines/checklist.html

## Dev environment

Repo has nix env (`shell.nix`/`flake.nix` + `.envrc`): run every repo tool
inside it (`nix-shell --run '<cmd>'` or direnv shell). Tool not in env:
`nix-shell -p <pkg> --run '<cmd>'`. Why: host, nix, CI versions drift; host
tool gives stale snapshots, CI-only failures.

zsh: separator `---`; test `[ x = y ]`. (`==` triggers `=cmd` expansion:
`(eval):1: == not found`.) Absolute paths; cwd drifts after `cd`.

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

@RTK.md
