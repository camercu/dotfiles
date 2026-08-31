---
name: test-design-reviewer
description: Use when user asks to review tests, assess a suite design quality, coverage or bug-catching power, or to hunt weak, flaky, tautological or untested behaviors.
context: fork
agent: Explore
model: sonnet
---

# Test Design Reviewer

## Overview

Review a test suite on three axes: **quality** (Dave Farley's 8 properties → a
Farley Index 0-10), **completeness** (coverage), and **efficacy** (do the tests
actually catch bugs?). Output = the Index with per-property evidence,
tautology-theatre findings, ranked fixes, a Coverage Review, and an Efficacy
Review (assertion-strength audit + mutation testing when available).

## Boundaries

Never modify source or tests — no Write/Edit/rename/delete, don't add tests to
chase coverage. **Running** the suite / a coverage or mutation tool is allowed:
it reads code and emits reports to the build/output dir (leave those artifacts
where the tool puts them; don't commit them). A mutation tool rewrites source in
place then restores it, and drops an output dir (e.g. `mutants.out/`) — expected,
not a boundary breach; leave it, suggest gitignoring, don't commit. Report is
structured text. Consumer requesting
fixes → point to the recommendations; the caller (e.g. harden TDD slice)
implements.

## Three lenses, kept separate

They measure different things; never fold them into one number.

- **Quality** — the **Farley Index**. How well-crafted the tests that exist are.
- **Completeness** — the **Coverage Review**. Whether behaviors have any test at
  all. The Index says nothing about *missing* tests (`Necessary` flags low-value
  *surplus*, never absence).
- **Efficacy** — the **Efficacy Review**. Whether the tests actually *catch bugs*.
  A covered line asserted-weakly is executed but unverified; coverage can't see
  this, only assertion strength and mutation testing can.

Read together: high Index + thin coverage = well-crafted tests of too little;
high coverage + low efficacy = tests that run the code but wouldn't notice it
breaking (coverage theatre).

## The 8 properties

| Code | Property | Weight | Measures |
|---|---|---|---|
| U | Understandable | 1.50x | Reads like a spec; behavior-named; clear structure |
| M | Maintainable | 1.50x | Verifies behavior not implementation; survives refactor |
| R | Repeatable | 1.25x | Deterministic; no time/fs/network dependence |
| A | Atomic | 1.00x | Isolated; no shared mutable state; parallelizable |
| N | Necessary | 1.00x | Adds unique value; no redundant/trivial assertions |
| G | Granular | 1.00x | Single outcome per test; failure pinpoints the issue |
| F | Fast | 0.75x | Pure computation; no I/O or sleeps |
| T | First (TDD) | 1.00x | Evidence of test-first; tests drove design |

U/M highest (tests-as-doc + refactor-survival = long-term value). F lowest (a
slow well-designed test beats a fast bad one).

## Farley Index

```
Farley Index = (U*1.5 + M*1.5 + R*1.25 + A*1.0 + N*1.0 + G*1.0 + F*0.75 + T*1.0) / 9.0
```

Each property 0.0-10.0. Divisor 9.0 = sum of weights (not 8). Compute the
weighted mean directly and show the arithmetic — no external calculator.

## Per-property rubric (0-10)

Score each property from the code, citing evidence. Bands:

**U — Understandable**
- 9-10: reads like a spec; descriptive names, clear organization
- 5-6: needs some code inspection to grasp intent
- 1-2: `test1`/`test2`, magic numbers, no structure

**M — Maintainable**
- 9-10: proper abstractions; refactoring rarely breaks tests; asserts behavior
- 5-6: some implementation coupling; over-specified mock interactions
- 1-2: reflection into privates; tests mirror implementation structure
- Flag: `verify()` with exact counts/ordering/`verifyNoMoreInteractions`,
  ArgumentCaptor deep-inspecting internal state, mock expectations mirroring
  if/else branches, high verify-to-assert ratio. Plain `verify(mock).method()`
  for a side effect is fine — flag only when it over-constrains implementation.

**R — Repeatable**
- 9-10: fully deterministic; no external deps
- 5-6: occasional flakiness; timing/state dependence
- 1-2: `sleep`, file I/O, network, system clock, unseeded random

**A — Atomic**
- 9-10: isolated; no shared state; parallelizable
- 5-6: some shared state; order sometimes matters
- 1-2: shared mutable static state; explicit ordering annotations

**N — Necessary**
- 9-10: every test unique value; parameterized for variations
- 5-6: checkbox tests; moderate redundancy
- 1-2: `assertTrue(true)`, disabled tests accumulating, mock-return-only tests

**G — Granular**
- 9-10: single outcome per test; failure pinpoints
- 5-6: multiple behaviors per test; diagnosis takes effort
- 1-2: mega-tests, 20+ assertions, `testEverything()`
- "Single outcome" ≠ "single assertion": multiple asserts for one outcome
  (status + body of a response) are fine. Flag *unrelated* asserts, not groups.

**F — Fast**
- 9-10: pure computation, millisecond
- 5-6: some slow tests; noticeable suite time
- 1-2: `sleep`, network, heavy setup/teardown

**T — First (TDD evidence, indirect)**
- 9-10: clear test-first; tests drive design; behavior-focused names
- 5-6: unclear; tests may be afterthoughts
- 1-2: structure mirrors implementation; coverage patches; no SUT exercised
- Static evidence is weak here — lean on judgment, note it. Tests exercising no
  real production code could not have been written test-first.

Multi-property signals count for each (e.g. `Thread.sleep` hits both R and F).
**Evidence or it's a guess**: every score cites `file:line` + signal.
**Conservative base 5.0** when a property shows no signal — unknown ≠ good.

## Tautology theatre

The plugin's signature check. A tautology-theatre test's outcome is
predetermined by its own setup, independent of production code. Defining
question: **"Would this still pass if all production code were deleted?"** Yes →
tautology theatre (zero value, inflates coverage). Four types:

- **Mock tautology** — configures a mock's return, then asserts the mock returns
  it, no production code between. `x = 5; assert x == 5`. (hits N, M)
- **Mock-only test** — every object a mock; no real class instantiated. (N, M, T)
- **Trivial tautology** — always-true regardless of code: `assertTrue(true)`,
  `assertEquals(1, 1)`, `assertNotNull(new Object())`. (N)
- **Framework test** — verifies language/framework, not app code:
  `assertNotNull(mock(Foo.class))`, `assertTrue("hello".contains("ell"))`. (N)

## Assertion strength

Tautology theatre is the floor (asserts *nothing*); assertion strength is the
gradient above it (asserts something, but too weak to catch a bug). The audit
question per test: **"If the production logic were subtly wrong, would this
assertion go red?"** No → weak. Smells:

- **Existence-only** — asserts not-null / not-throws / "it ran", never the value.
- **Shape not content** — asserts `list.len() == 3` but not *which* elements;
  status `200` but not the body; a type but not the data.
- **Interaction not outcome** — asserts a mock/spy *was called* instead of the
  observable effect (ties to Maintainable over-specification).
- **Over-broad** — a giant snapshot that "pins" everything and therefore nothing
  specific; `contains(x)` where exact equality is the real contract.
- **Missing negative space** — only the happy path; no error / rejection /
  boundary assertion. Untested error handling is the highest-risk case.
- **Self-referential oracle** — expected value recomputed in the test the same
  way production computes it, so both are wrong together. Prefer a hardcoded /
  independently-derived expected.
- **Loose tolerance** — `assert x > 0` when the exact expected is known.

Strong = pins the *essential* observable outcome for a specific input, exact
where the contract is exact, and covers the negative space. Rank tests by
bug-catch confidence; the weak ones are where mutation testing will find
survivors.

## Process

1. **Discover** — find test files; detect language + test/mock frameworks. Apply
   language-appropriate patterns (don't score Python like Java).
2. **Read tests first**, before implementation. Per test method: scan negative
   signals (sleep, reflection, shared state, ordering, I/O, magic numbers,
   cryptic names, trivial asserts, mega-tests), positive signals (behavior
   names, AAA structure, parameterization, isolation), tautology theatre,
   assertion strength; record `file:line`; count assertions.
3. **Score** each property 0-10 from rubric + evidence. Aggregate method → file
   (mean of positives, worst-case for negatives) → suite. Compute Farley Index.
4. **Cover** (below): hunt behavior gaps manually + run a coverage tool if one's
   available.
5. **Verify efficacy** (below): the assertion-strength audit from step 2, plus
   mutation testing if a tool's available.
6. **Report** (below): worst offenders, tautology theatre, ranked fixes,
   coverage, efficacy.

## Coverage review

Runs last, after scoring. Completeness, not quality — reported separately from
the Index. Two lenses:

**Manual (behavior gaps) — the primary lens.** Trace each observable behavior to
a test that exercises it: every public API entry, each acceptance-criterion / spec
item, error and edge paths, boundary conditions, and the wiring/integration seams
between units (untested wiring = the classic miss). List *behaviors* with no
exercising test, not just uncovered lines. A line executed by a test that asserts
nothing on it is **covered but untested** — call these out (they tie back to
tautology theatre); a covered line is not a tested behavior.

**Programmatic (a coverage tool) — best-effort.** Detect the stack's tool from
project config/lockfiles; confirm it's installed (`--version`) before running;
prefer a project runner that already wraps it (`just coverage`, an npm script).
If present and the suite runs in reasonable time, run it, then report overall
line/branch % and the largest uncovered spans (`file:line-range`) — discount
spans covered only by `#[ignore]`/subprocess/root tests the tool didn't execute.
If the wrapped runner *fails* (common cause: tests with process-global side
effects — fd/signal/env — corrupt the shared test harness), retry the tool
directly or via a per-test-isolating runner (e.g. `cargo llvm-cov nextest`)
before giving up. If no tool is installed, it errors, or the run is prohibitively
slow → **say so and fall back to manual-only. Never fail the review over coverage
tooling.**

| Stack | Tool (best-effort) |
|---|---|
| Rust | `cargo llvm-cov` (preferred), else `cargo tarpaulin` |
| Python | `pytest --cov` / `coverage run -m pytest` (coverage.py) |
| JS/TS | `vitest run --coverage`, `jest --coverage`, `c8`, `nyc` |
| Go | `go test ./... -coverprofile=… ` + `go tool cover` |
| Java | JaCoCo via `mvn test` / `gradle test` |
| C# | `dotnet test --collect:"XPlat Code Coverage"` (coverlet) |

Reconcile the two: prefer behavior gaps (an uncovered line names a definite gap;
100% line coverage still proves nothing about assertions). Rank gaps by risk —
untested error handling and security/permission paths first.

## Efficacy review

Do the tests *catch bugs*? Coverage can't answer this — a covered line with a
weak assertion is executed but unverified. Two lenses:

**Assertion strength (static) — always runs.** The audit above: rank tests by
bug-catch confidence, list the weak ones with the specific smell and what a
sharper assertion would pin.

**Mutation testing (programmatic) — best-effort.** The ground truth: perturb the
production code (flip `>`↔`>=`, `&&`↔`||`, delete a statement, swap a return) and
re-run the tests. A mutant the tests **kill** (turn red) = that behavior is
genuinely verified; a **survivor** = code changed and no test noticed. Report the
**surviving mutants**, not just the score — but a survivor is a *candidate* gap,
not proof of one. **Triage each** before reporting it; half the work of a good
mutation review is discarding false gaps:

- **Real gap** — a reachable behavior no test pins. The actionable finding; name
  it at `file:line` with the sharper assertion that would kill it.
- **Equivalent mutant** — semantically identical to the original, so unkillable
  (e.g. `|`→`^` on disjoint bit-flags, `x*1`, a reorder with no observable
  effect). Not a gap.
- **Unreachable / dead-defensive** — a branch/arm no input can produce by
  construction. Points at dead code, not a test hole.
- **Tested only outside the run** — killed only by an `#[ignore]`/subprocess/root
  test the default mutation run skips (common for process-global effects:
  fd/signal/env/fork). Reconcile against those before calling it a gap.
- **Timeout** — the mutation hung the suite (diverged loop, blocked read); the
  tests *detected* it. Count as killed unless it's merely a slow-but-correct test.

Survivors clustering in one module — typically the imperative shell around
syscalls — is expected: the pure core is killable in-process, the shell is
integration territory. Say so rather than filing each as a defect.

Rules: detect the stack's tool; confirm installed (`--version`) before running.
Mutation runs the suite once *per mutant* — it is slow: **time-box it and scope
tight** (changed files / the review target / `--in-diff`), never the whole
repo blind. Coverage upper-bounds it (a mutant on an uncovered line can't be
killed), so run it on covered, load-bearing code. No tool, too slow, or it
errors → **say so and let the assertion-strength audit stand as the efficacy
verdict. Never fail the review over mutation tooling.**

| Stack | Tool (best-effort) |
|---|---|
| Rust | `cargo mutants` (cargo-mutants) |
| Python | `mutmut`, `cosmic-ray` |
| JS/TS | Stryker (`@stryker-mutator`) |
| Java | PIT (`pitest`) |
| Go | `gremlins`, `go-mutesting` |
| C# | Stryker.NET (`dotnet stryker`) |

## Report format

Report file open **before** the lenses run; fill it in as you go, section by
section. Mutation/efficacy work especially — each survivor written the moment
it survives, with the mutation applied and the tests that stayed green. That
work is expensive to redo and is exactly what a session limit eats. Never hold
a run's results in context to write up at the end.

```
# Test Design Review

## Farley Index: X.X / 10.0 (Rating)

### Property Breakdown

| Property | Score | Weight | Weighted | Key Evidence |
|---|---|---|---|---|
| Understandable | X.X | 1.50x | X.XX | file:line ... |
| Maintainable   | X.X | 1.50x | X.XX | ... |
| Repeatable     | X.X | 1.25x | X.XX | ... |
| Atomic         | X.X | 1.00x | X.XX | ... |
| Necessary      | X.X | 1.00x | X.XX | ... |
| Granular       | X.X | 1.00x | X.XX | ... |
| Fast           | X.X | 0.75x | X.XX | ... |
| First (TDD)    | X.X | 1.00x | X.XX | ... |

### Tautology Theatre

Per type (Mock / Mock-only / Trivial / Framework): test method, line, evidence.
Use "None detected." when empty. Summary line: N instances across M of T methods.

### Top Worst Offenders

1. file:method — Farley X/10 — key issues
2. ...

### Recommendations

Ranked by impact — fix the lowest-scoring high-weight properties first.
1. ...

### Coverage Review

Separate from the Farley Index — completeness, not quality.

**Programmatic** ({tool}, or "no coverage tool available — manual only"):
overall X% lines / Y% branches. Largest uncovered spans:
- file:line-range — what's untested

**Behavior gaps** (manual — behaviors with no exercising test, ranked by risk):
1. {behavior / acceptance-criterion} — untested — {where it lives}

**Covered but unasserted** (lines run by a test that asserts nothing on them):
- file:method — ...

### Efficacy Review

Separate from the Index — do the tests catch bugs?

**Assertion strength** (weak assertions, ranked by bug-catch risk):
1. file:method — {smell} — asserts {what}; a sharper test would pin {what}

**Mutation testing** ({tool} + scope, or "no tool available — assertion-strength
audit stands as the efficacy verdict"): score {killed}/{total} ({pct}%).
Surviving mutants (triaged — real gaps first, then dismissed with reason):
- file:line — {mutation, e.g. `>` → `>=`} survived — {real gap: sharper test that
  kills it | equivalent / dead / tested-out-of-run / timeout: why it's not a gap}

### Dimensions Not Measured

Predictive, Inspiring, Composable, Writable (Beck's Test Desiderata — need
runtime or team context, not assessable from test code alone).

### Reference

Dave Farley, Properties of Good Tests:
https://www.linkedin.com/pulse/tdd-properties-good-tests-dave-farley-iexge/
```

## Rating scale

| Farley Index | Rating | Interpretation |
|---|---|---|
| 9.0-10.0 | Exemplary | Model suite; tests are living documentation |
| 7.5-8.9  | Excellent | High quality; minor improvements |
| 6.0-7.4  | Good      | Solid; clear improvement areas |
| 4.5-5.9  | Fair      | Functional; needs design attention |
| 3.0-4.4  | Poor      | Limited value; major refactor needed |
| 0.0-2.9  | Critical  | May be harmful; consider rewriting |

## Attribution

Framework: Dave Farley's Properties of Good Tests. Scoring + tautology-theatre
methodology: Andrea LaForgia's test-design-reviewer. Distilled from the
[farley_score_plugin](https://github.com/mse-online/farley_score_plugin) —
stripped to the rubric, dropping its Python calculator, static/LLM blend,
sampling, and coach/demo modes; adds coverage and efficacy (assertion-strength +
mutation-testing) reviews the plugin (quality-only, by design) omits.
