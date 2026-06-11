---
name: tdd
description: Test-driven development with red-green-refactor loop. Use when user wants to build features or fix bugs using TDD, mentions "red-green-refactor", "tdd", wants acceptance tests, or asks for test-first development.
---

# Test-Driven Development

## Context Loading

Load **progressively** — only when entering the phase that needs them.

| When                     | Load                                   |
| ------------------------ | -------------------------------------- |
| Planning                 | `deep-modules.md`, `tracer-bullets.md` |
| First infrastructure dep | `testing-without-mocks.md`             |
| Test doubles needed      | `interface-design.md`                  |
| Refactor phase           | `refactoring-smells.md`                |

Cross-refs: `/improve-architecture` (module-level), `/simplify` (code-level cleanup).

## Philosophy

- **Test first.** No production code before its test. For feature *changes*, reviewing/updating existing tests first counts.
- **Behavior, not implementation.** Test through public interfaces — verify through the interface, not around it (see [interface-design.md](./interface-design.md#5-verify-through-the-interface)). Tests survive internal refactors.
- **Functional core, imperative shell.** Pure functions for decisions, I/O at edges. Shell stays thin — verified by inspection or narrow integration test.
- **Sociable, state-based, independent.** Real collaborators; assert outputs, not call sequences (Chicago school). No shared mutable state or ordering deps. Doubles only at infrastructure boundaries; pick simplest: stub → fake → spy → nullable → mock. Mock only when call ordering IS the behavior. See [testing-without-mocks.md](./testing-without-mocks.md).
- **GIVEN-WHEN-THEN.** Tests as use-case scenarios, one condition asserted per test.
- **WET tests.** Production code DRY; test code optimized for readability. Duplicate setup fine if intent obvious; helpers that hide the GIVEN hurt.
- **Test pyramid.** ~80% unit / 15% integration / 5% E2E. Top-heavy suite = logic coupled to infrastructure.
- **One test → one impl → repeat.** Never write all tests up front — bulk tests test *imagined* behavior. Friction writing tests = design feedback; fix the design.
- **Call your shots.** Predict the failure, run, confirm it fails for that reason. Mismatch reveals misunderstanding.
- **Fast and deterministic.** Whole suite ≤10s, zero flakes.
- **Prove-It rule.** No bug fix without a failing reproduction test first; passing test = fixed + regression-proofed.

## Workflow: Double Loop

```
OUTER (acceptance):
  Failing acceptance test → GIVEN-WHEN-THEN spec of user-facing behavior
    INNER (unit):
      RED → GREEN → REFACTOR (repeat)
  Acceptance passes → feature done → coverage audit
```

### 1. Plan

- [ ] Confirm interface changes + which behaviors to test (prioritize — can't test everything)
- [ ] Write acceptance criteria as GIVEN-WHEN-THEN
- [ ] Design for [deep modules](./deep-modules.md) + [testability](./interface-design.md)
- [ ] Plan [tracer bullet](./tracer-bullets.md) — thinnest vertical slice first
- [ ] Get user approval

### 2. Acceptance Test (outer RED)

**Features:** ONE failing acceptance test through the public interface; stays RED during inner loop. Feature change → review existing tests for new behavior before adding new ones.

**Bug fixes:** Prove-It rule above.

### 3. TDD Loop (inner)

Drive implementation until acceptance test passes. One test at a time; don't anticipate future tests.

**RED:** Write next test → call your shot → run. Test passing immediately is suspect (vacuous, wrong target, or impl exists) — investigate.
**GREEN:** Minimal code to pass. Run the suite — no "should pass."
**REFACTOR:** [Refactoring smells](./refactoring-smells.md). Deepen modules, extract pure functions, improve readability. Never refactor while RED. Tests don't change except for renamed APIs.

Use ZOMBIES (Zero, One, Many, Boundaries, Interface-design, Exceptions/Edge-cases, Simplify) to pick what to test next for each new API surface.

### 4. Acceptance GREEN → Done

### 5. Code Review

Coverage audit: edge cases, error paths, boundaries. Consider **property-based tests** (Hypothesis/proptest) for broad input domains.

Then review and refactor via `/code-review`, `/simplify`, `/improve-architecture`. Tests stay GREEN throughout (design changes only, no behavior changes).

## Checklist

```
[ ] GIVEN-WHEN-THEN, one assertion per test
[ ] Public interface only, verifies through it
[ ] Survives internal refactor
[ ] Independent (no shared state, no ordering)
[ ] Minimal code, no speculative features
[ ] Actually ran tests — no "should pass" or "probably works"
[ ] Code review and refactor after GREEN to simplify/clean up design
```
