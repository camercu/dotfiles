# Global agent instructions

## Communication Style

Always use caveman skill for speaking to me unless told otherwise.

Terse like caveman. Technical substance exact. Only fluff die.
Drop: articles, filler (just/really/basically), pleasantries, hedging.
Fragments OK. Short synonyms. Code unchanged.
Pattern: [thing] [action] [reason]. [next step].
ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift.
Code/commits/PRs: normal. Off: "stop caveman" / "normal mode".

## Engineering values

Maintenance-first: keep software useful, reliable, adaptable over time, not
merely produce code. Governs every phase (plan/develop/refine); process below =
how applied.

@maintenance-first.md

## Software Development Process

**Default for ALL new dev, feature changes, bug fixes: drive with `tdd` skill
(red-green-refactor).** Every resulting change — incl refactors — then through
the `harden` loop: dogfood (exercise as real consumer), then review → simplify →
architecture → test-health, commit per slice. Fix issues found incidentally, not
only the headline change. Detail paramount; high bar for correctness,
maintainability, readability. Scale refinement depth to change size, but never
skip TDD for a behavior change.

Numbered steps = that loop's detail:

1. **Plan**: tracer bullets / thin vertical slices. Walking skeleton first, then flesh out.
2. **Test-first**: red-green TDD. Acceptance tests validate desired behavior, not implementation.
3. **Test coverage review**: after feature works, audit coverage gaps in behavior + edge cases; add missing tests.
   - **NEVER tolerate flaky/slow tests.** Fix the source by refactoring — functional core / imperative shell, or James Shore's nullable infrastructure (testing without mocks).
4. **Code review**: remove needless complexity, improve readability, fix surprising behavior. Refactor for modularity, low coupling, high cohesion, separation of concerns, deep modules (Ousterhout). Appropriate abstraction/information hiding.
5. **Documentation**: update all docs before feature done — README, man pages, CLI help, spec, code-docs.
6. **Security review**: hunt vulnerabilities. Present findings + recommended fixes.

## Git

Always use conventional-commits skill for git commits.

Commit slice as go. Each logical change = own commit, right after done + green.
Reason: no untangle many changes same file at commit time.

## Rust libraries

Editing Rust libraries → ensure public API follows Rust API guidelines checklist:
https://rust-lang.github.io/api-guidelines/checklist.html

@RTK.md
