# Global agent instructions

## Writing

| Text | Register | Skill |
|---|---|---|
| Chat to user | caveman full | — |
| Agent-read: AGENTS.md, CLAUDE.md, memory, skills, subagent prompts, briefs | caveman full | `writing-for-agents` |
| Commits, PRs, code comments | caveman lite | `unslop` incl. `technical.md`, no soul |
| Other public text for user: docs, emails, posts | plain | `unslop` |

@caveman.md

- Use terms from `CONTEXT.md` when present.
- Question, gate, or fork for user: chat prose. Numbered options, own
  recommendation, reasons. Give enough context (real code, exact API) so user
  decides without reading history or diffs. Then wait.

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
- Fresh agent reviews own work: context that authored the code spawns a fresh
  reviewer unless a human vets the findings. Already a spawned reviewer →
  review in place.
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
