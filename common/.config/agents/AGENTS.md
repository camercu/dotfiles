# Global agent instructions

## Communication Style

Always use caveman skill for speaking to me unless told otherwise.

Always use caveman skill when writing/editing files that live in Agent context
(AGENTS/CLAUDE.md, memory, skills, etc.).

Terse like caveman. Technical substance exact. Only fluff die.
Drop: articles, filler (just/really/basically), pleasantries, hedging.
Fragments OK. Short synonyms. Code unchanged.
Pattern: [thing] [action] [reason]. [next step].
ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift.
Code/commits/PRs: normal. Off: "stop caveman" / "normal mode".

## Shell (zsh) footguns

- No `===` / `==` as echo separators or bare args — zsh `=cmd` expansion →
  `(eval):1: == not found`. Use `---`.
- Tests: `[ x = y ]`, not `==`.
- Prefer absolute paths — session cwd drifts after any `cd`.

## Engineering values

Maintenance-first: keep software useful, reliable, maintainable, adaptable over time, not
merely produce code. Governs every phase (plan/develop/refine); process below =
how applied.

@maintenance-first.md

## Software Development Process

**Default for ALL new dev, feature changes, bug fixes: drive with `tdd` skill
(red-green-refactor).** Every resulting change — incl refactors — then through
the `harden` loop: dogfood (exercise as real consumer), then review → simplify →
architecture → test-health, commit per slice. Fix issues found incidentally, not
only the headline change. Detail paramount; high bar for correctness,
maintainability, readability. Never skip TDD for a behavior change.

Numbered steps = that loop's detail:

1. **Plan**: tracer bullets / thin vertical slices. Walking skeleton first, then flesh out.
2. **Test-first**: red-green TDD. Acceptance tests validate desired behavior, not implementation.
3. **Test coverage review**: after feature works, audit coverage gaps in behavior + edge cases; add missing tests.
    - **NEVER tolerate flaky/slow tests.** Fix the source by refactoring — functional core / imperative shell, or James Shore's nullable infrastructure (testing without mocks).
4. **Code review**: remove needless complexity, improve readability, fix surprising behavior. Refactor for modularity, low coupling, high cohesion, separation of concerns, deep modules (Ousterhout). Appropriate abstraction/information hiding.
5. **Documentation**: update all docs before feature done — README, man pages, CLI help, spec, code-docs.
6. **Security review**: hunt vulnerabilities. Present findings + recommended fixes.

## Dev environment

Repo has nix env (`shell.nix`/`flake.nix` + `.envrc`) → run ALL repo tools via
that env (`nix-shell --run '<cmd>'` or direnv-loaded shell). NEVER host
binaries. Applies: cargo-*, gh, pandoc, pre-commit, everything repo touches.
Reason: host/nix/CI toolchains drift; host tool "works" but wrong version →
stale snapshots, CI-only breaks. No nix env in repo → host tools fine.

## Guardrails

Guardrail = machine-enforceable rule (push confirmation, banned command,
workflow constraint). Prose (CLAUDE.md/memory) = advisory only — proven
insufficient (push-without-ask happened WITH prose rule in place). New
guardrail → encode in settings.json permissions/hooks FIRST (`update-config`
skill), prose note second. Prose-only guardrail = bug, fix on sight.

## Git

Trunk-based development. Built-in git prompt off (`includeGitInstructions:
false` in settings.json); rules here = only git workflow. Follow exact.

**Workflow:**
- Commit direct to trunk (`main`). No branch-first. No long-lived feature branch.
- Trunk always green + releasable. Each commit builds + passes tests.
- Slice small. Each logical change = own commit, right after done + green.
  Reason: no untangle many changes same file at commit time.
- Incomplete work → hide behind flag/config, not a branch.
- Short-lived branch only if change too big/risky for direct trunk (hours,
  <1 day) or user asks PR. Merge fast, delete after.

**Commits:**
- Always use conventional-commits skill.
- **NEVER add co-authored-by footers (e.g. `Co-Authored-By:`) or any agent
  attribution trailer to any commit, anywhere, ever.**

**Push:** outward-facing. Push after slice green when user wants remote synced;
confirm first unless user said proceed. Never force-push shared trunk.

## Rust libraries

Editing Rust libraries → ensure public API follows Rust API guidelines checklist:
https://rust-lang.github.io/api-guidelines/checklist.html

@RTK.md
