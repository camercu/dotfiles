---
name: test-design-reviewer
description: Evaluates test quality using Dave Farley's 8 properties, producing a Farley Index (0-10) with per-property evidence, tautology-theatre findings, prioritized fixes, and a closing coverage review (manual gap-hunt + a coverage tool when available). Use when reviewing tests, assessing a test suite's design quality or coverage, or hunting weak/flaky/tautological tests or untested behaviors.
context: fork
agent: Explore
model: sonnet
---

# Test Design Reviewer

Score test quality against Dave Farley's 8 properties, then close with a coverage
review. Output = a **Farley Index (0-10)** with per-property scores, evidence,
tautology-theatre findings, ranked fixes, **and a final Coverage Review** (manual
behavior-gap hunt + a coverage tool when one's available).

## Boundaries

Never modify source or tests — no Write/Edit/rename/delete, don't add tests to
chase coverage. **Running** the suite / a coverage tool is allowed: it reads code
and emits reports to the build/output dir (leave those artifacts where the tool
puts them; don't commit them). Report is structured text. Consumer requesting
fixes → point to the recommendations; the caller (e.g. harden TDD slice)
implements.

## Two scores, kept separate

The **Farley Index grades quality** of the tests that exist — it says nothing
about *missing* tests. A suite of excellent tests can leave whole behaviors
untested and still score high (`Necessary` flags low-value *surplus*, never
absence). So the review **ends with a distinct Coverage Review** measuring
completeness, reported separately and **never folded into the Index**. Read them
together: high Index + thin coverage = well-crafted tests of too little.

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

## Process

1. **Discover** — find test files; detect language + test/mock frameworks. Apply
   language-appropriate patterns (don't score Python like Java).
2. **Read tests first**, before implementation. Per test method: scan negative
   signals (sleep, reflection, shared state, ordering, I/O, magic numbers,
   cryptic names, trivial asserts, mega-tests), positive signals (behavior
   names, AAA structure, parameterization, isolation), tautology theatre; record
   `file:line`; count assertions.
3. **Score** each property 0-10 from rubric + evidence. Aggregate method → file
   (mean of positives, worst-case for negatives) → suite. Compute Farley Index.
4. **Cover** (below): hunt behavior gaps manually + run a coverage tool if one's
   available.
5. **Report** (below): worst offenders, tautology theatre, ranked fixes, coverage.

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
line/branch % and the largest uncovered spans (`file:line-range`). If no tool is
installed, it errors, or the run is prohibitively slow → **say so and fall back to
manual-only. Never fail the review over coverage tooling.**

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

## Report format

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
sampling, and coach/demo modes; adds a closing coverage review the plugin
(quality-only, by design) omits.
