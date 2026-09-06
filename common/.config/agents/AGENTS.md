# Global agent instructions

## Communication Style

### Communicating to agents

Always use caveman skill when writing/editing files that live in Agent context
(AGENTS/CLAUDE.md, memory, skills, etc.).

Use **progressive disclosure**: specialized details in separate file, pointed to
with note on when to reference.

**Point to the source of truth** rather than restate what can be discovered by
reading the source (e.g. source code, reference) and indicate when/why
agent should look there. Only summarize if it meaningfully saves context (reading
whole long document not worthwhile just to glean small number of ideas). Use
regular expression search phrases or line numbers to point to specific
sub-sections of interest, easing burden of finding the right thing.

**State the target.** Describe and direct desired behavior positively,
rather than steering by prohibition (prohibition tends to drag
forbidden behavior into context, making it more likely). A
prohibition earns its place only as a hard guardrail you cannot
phrase positively; even then, pair it with the positive target so
attention lands on what to do.

### Communicating to user

Always use `/caveman` skill for speaking to user unless told otherwise.

**Never use AskUserQuestion.** Every gate, fork, clarification → chat prose:
numbered options + own recommendation with thorough, well-reasoned justification,
wait for reply. Always supply enough context in the chat for the user to
understand and decide without digging through history / diffs. Be specific and accurate
(e.g. actual code snippets showing API, vs vague description).

Talk in ASD-STE100 Simplified Technical English, and use the ubiquitous language
from CONTEXT.md, if present.

### Communicating to world on behalf of user

When ghostwriting for user on public-facing text (docs, comments, PRs, etc.), always use `/unslop` skill.

## Engineering values

Maintenance-first: keep software maintainable, readable, reliable, adaptable over time, not
merely produce working code. Governs every phase (plan/develop/refine); process below =
how applied.

@maintenance-first.md

## Defect prevention

Bug found, or same mistake twice → fix the class, not the instance. Order
strict; lower tier only when higher genuinely cannot reach:

1. **Make it impossible.** Types, data structures, architecture. Bad state
   unrepresentable, wrong call won't compile. No discipline to keep, no test to
   rot, no reviewer to catch it. Ask this first, every time.
2. **Make it fail by itself.** Test, custom lint, CI gate, exhaustive match.
   For what types can't express. Must fail loud on the real mistake, not near
   it.
3. **Prose.** Docs, comments, memory. Advisory only. Never alone for a mistake
   that can recur.

Prose-only guard on a repeatable mistake = bug, fix on sight. Same rule
Guardrails sets for the harness, applied to code.

A mistake made twice means the design permitted it. Fix the design, not the second instance.

Smells that design is letting the error in:

- comment says "remember to" / "callers must"
- fix is "be careful next time"

## Software Development Process

**Default for ALL new dev, feature changes, bug fixes: drive with `/tdd` skill
(red-green-refactor).** Every resulting change — incl refactors — then through
the `/harden` loop: dogfood (exercise as real consumer), then review → simplify →
architecture → test-health, commit per slice. Fix issues found incidentally, not
only the headline change. Detail paramount; high bar for correctness,
maintainability, readability. Never skip TDD for a behavior change.

Numbered steps = that loop's detail:

1. **Plan**: tracer bullets / thin vertical slices. Walking skeleton first, then flesh out.
2. **Test-first**: red-green TDD. Acceptance tests validate desired behavior, not implementation.
3. **Test coverage review**: after feature works, audit coverage gaps in behavior + edge cases; add missing tests.
    - **NEVER tolerate flaky/slow tests.** Fix the source by refactoring — functional core / imperative shell, or James Shore's nullable infrastructure (testing without mocks).
4. **Code review**: remove needless complexity, improve readability, fix surprising behavior. Refactor for modularity, low coupling, high cohesion, separation of concerns, deep modules (Ousterhout). Appropriate abstraction/information hiding.
    - Author of code is never the reviewer: invoke a subagent for review steps if necessary.
5. **Documentation**: update all docs before feature done — README, man pages, CLI help, spec, code-docs.
6. **Security review**: hunt vulnerabilities. Present findings + recommended fixes.

**Named skill = real Skill invocation.** Process names a skill (`code-review`,
`simplify`, `improve-architecture`, `dogfood`, `grill-me`) → call it. Inline
reasoning supplements, never substitutes. Skipping the call and reporting the
pass as run = fabricated. Can't run it → mark SKIPPED w/ reason. Own work
reviewed by a FRESH agent, never self-review in-context — fresh context is what
buys the reach.

### Rust libraries

Editing Rust libraries → ensure public API follows Rust API guidelines checklist:
https://rust-lang.github.io/api-guidelines/checklist.html

## Dev environment

Repo has nix env (`shell.nix`/`flake.nix` + `.envrc`) → run ALL repo tools via
that env (`nix-shell --run '<cmd>'` or direnv-loaded shell). NEVER host
binaries. Applies: cargo-\*, gh, pandoc, pre-commit, everything repo touches.
Reason: host/nix/CI toolchains drift; host tool "works" but wrong version →
stale snapshots, CI-only breaks. No nix env in repo → host tools fine.

### Shell (zsh) footguns

- No `===` / `==` as echo separators or bare args — zsh `=cmd` expansion →
  `(eval):1: == not found`. Use `---`.
- Tests: `[ x = y ]`, not `==`.
- Prefer absolute paths — session cwd drifts after any `cd`.

## Guardrails

Guardrail = machine-enforceable rule (push confirmation, banned command,
workflow constraint). Prose (CLAUDE.md/memory) = advisory only — proven
insufficient (push-without-ask happened WITH prose rule in place). New
guardrail → encode in settings.json permissions/hooks FIRST (`update-config`
skill), prose note second.

## Git

Trunk-based development. Built-in git prompt off (`includeGitInstructions:
false` in settings.json); rules here = only git workflow. Follow exact.

**Workflow:**

- Commit direct to trunk (`main`). No branch-first. No long-lived feature branch.
- Trunk always green + releasable. Each commit builds + passes tests.
- Slice small. Each logical change = own commit, right after done + green.
  Reason: no untangle many changes same file at commit time.
- Incomplete work → use branch by abstraction or hide behind keystone interface/flag/config, not a branch.
- Short-lived branch only if change too big/risky for direct trunk (hours,
  <1 day) or user asks PR. Merge fast, delete after.

**Commits:**

- Always use conventional-commits skill.
- **NEVER add co-authored-by footers (e.g. `Co-Authored-By:`) or any agent
  attribution trailer to any commit, anywhere, ever.**
- Each review finding = own commit. No bundled "fix all findings" commit.

**Push:** outward-facing. Push after slice green when user wants remote synced;
confirm first unless user said proceed. Never force-push shared trunk.
Repo runs semantic-release → fetch + rebase onto remote trunk immediately before
every push (release bot lands `chore(release)` commits between sessions).

@RTK.md
