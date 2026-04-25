---
name: tdd
description: Test-driven development with red-green-refactor loop. Use when user wants to build features or fix bugs using TDD, mentions "red-green-refactor", "tdd", wants acceptance tests, or asks for test-first development.
---

# Test-Driven Development

## Context Loading

Load **progressively** — only when entering the phase that needs them.

| When | Load |
|------|------|
| Planning | `deep-modules.md`, `tracer-bullets.md` |
| First infrastructure dep | `testing-without-mocks.md` |
| Test doubles needed | `interface-design.md` |
| Refactor phase | `refactoring-smells.md` |

Cross-refs: `/improve-architecture` (module-level), `/simplify` (code-level cleanup).

## Philosophy

**Behavior, not implementation.** Test through public interfaces. Tests break only when behavior changes, not from internal refactors. Verify through the interface, not around it (see [interface-design.md](./interface-design.md#5-verify-through-the-interface)).

**Functional core, imperative shell.** Pure functions for decisions, I/O at edges. Core: values in, values out. Shell: thin, verified by inspection or narrow integration test.

**Sociable, state-based, independent.** Real collaborators, assert outputs not call sequences (Chicago school). Each test isolated — no shared mutable state, no ordering deps. Test doubles only at infrastructure boundaries. Pick simplest double: stub → fake → spy → nullable → mock. Mock only when call ordering IS the behavior. See [testing-without-mocks.md](./testing-without-mocks.md).

**GIVEN-WHEN-THEN.** One WHEN per test. See [interface-design.md](./interface-design.md) for examples.

**Test pyramid.** Many unit, fewer integration, few E2E. Top-heavy suite = logic coupled to infrastructure.

**No horizontal slices.** One test → one impl → repeat. Never write all tests first. Tests written in bulk test _imagined_ behavior. Tests are design feedback: hard to write → design issue.

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

Write ONE failing acceptance test. Exercises feature through public interface. Stays RED during inner loop.

### 3. TDD Loop (inner)

Drive implementation until acceptance test passes.

**RED:** Write next test → predict failure → run → fails as predicted.
**GREEN:** Minimal code to pass.
**REFACTOR:** [Refactoring smells](./refactoring-smells.md). Deepen modules, extract pure functions, improve readability. Never refactor while RED. Tests don't change except for renamed APIs.

Rules: one test at a time. Call your shots. Don't anticipate future tests. GIVEN-WHEN-THEN.

### 4. Acceptance GREEN → Done

### 5. Coverage Audit

Edge cases, error paths, boundary conditions. Consider **property-based tests** (Hypothesis/proptest) for broad input domains.

## Checklist

```
[ ] GIVEN-WHEN-THEN, one WHEN per test
[ ] Public interface only, verifies through it
[ ] Survives internal refactor
[ ] Independent (no shared state, no ordering)
[ ] Minimal code, no speculative features
```
