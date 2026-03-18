---
name: tdd
description: Test-driven development with red-green-refactor loop. Use when user wants to build features or fix bugs using TDD, mentions "red-green-refactor", "tdd", wants acceptance tests, or asks for test-first development.
---

# Test-Driven Development

## Philosophy

**Core principle**: Tests should verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't change unless requirements change.

**Good tests** are sociable and state-based: they exercise real code paths through public APIs, validating that given inputs produce expected outputs. They describe _what_ the system does, not _how_ it does it. A good test reads like a specification - "user can checkout with valid cart" tells you exactly what capability exists. These tests survive refactors because they don't care about internal structure. Good tests are also **fast** and **deterministic**. In most tests of program logic, inject fakes/stubs for external infrastructure like clocks, network connections, random number generators, file system/database accesses, etc. Only use the minimum set of focused, narrow integration tests to validate that the real code path and real external dependencies work together as expected. Refer to [testing without mocks](./testing-without-mocks.md) for more techniques on separating business logic from external infrastructure.

**Bad tests** are coupled to implementation. They mock internal collaborators when the user requirement doesn't dictate a specific collaboration pattern. They test private methods or internal state. The warning sign: your test breaks when you refactor, but behavior hasn't changed. If you rename an internal function or change the type of an internal data structure and tests fail as a result, those tests were testing implementation, not behavior.

## Anti-Pattern: Horizontal Slices

**DO NOT write all tests first, then all implementation.** This is "horizontal slicing" - treating RED as "write all tests" and GREEN as "write all code."

This produces **crap tests**:

- Tests written in bulk test _imagined_ behavior, not _actual_ behavior
- You end up testing the _shape_ of things (data structures, function signatures) rather than user-facing behavior
- Tests become insensitive to real changes - they pass when behavior breaks, fail when behavior is fine
- You outrun your headlights, committing to test structure before understanding the implementation

**Correct approach**: Vertical slices via [tracer bullets](./tracer-bullets.md). One test → one implementation → repeat. Each test responds to what you learned from the previous cycle. Because you just wrote the code, you know exactly what behavior matters and how to verify it.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
  ...
```

Additionally, you can use the tests as feedback that guides your design. If the
tests are hard to write, hard to reason about, or hard to maintain, there is
likely a design issue. Step back and reconsider your design and architecture.
Consider changing your interfaces. Tests should act as intention-revealing
documentation for your codebase. If you cannot easily read the test to
understand what your code does and how to use it, reconsider your design,
interfaces, and naming strategy.

## Workflow

### 1. Planning

Before writing any code:

- [ ] Confirm with user what interface changes are needed
- [ ] Confirm with user which behaviors to test (prioritize)
- [ ] Identify opportunities for [deep modules](./deep-modules.md) (small interface, deep implementation)
- [ ] Design interfaces for [testability](./interface-design.md)
- [ ] List the behaviors to test (not implementation steps)
- [ ] Get user approval on the plan

Ask: "What should the public interface look like? Which behaviors are most important to test?"

**You can't test everything.** Confirm with the user exactly which behaviors matter most. Focus testing effort on critical paths and complex logic, not every possible edge case.

### 2. Tracer Bullet

Write ONE test that confirms ONE thing about the system:

```
RED:   Write test for first behavior → test fails in the way you predict it should
GREEN: Write minimal functional code to pass → test passes
```

This is your tracer bullet - proves the path works end-to-end.

### 3. Incremental Loop

For each remaining behavior:

```
RED:   Write next test → fails in the way you predict
GREEN: Minimal code to pass → passes
```

Rules:

- One test at a time
- "Call your shots" by predicting how a new test will fail. This validates your understanding of the codebase
- Only write enough code to pass current test
- Don't anticipate future tests
- Keep tests focused on observable behavior

### 4. Refactor

After all tests pass, use a subagent to look for [refactor candidates](refactoring.md). Goals:

- [ ] Improve modularity
- [ ] Increase cohesion
- [ ] Improve separation of concerns
- [ ] Ensure appropriate abstraction (hide only information that the user of the code does not need to be aware of)
- [ ] Reduce/eliminate unnecessary coupling
- [ ] Reduce/eliminate accidental (unnecessary) complexity
- [ ] Improve readability by renaming/restructuring to reveal intent
- [ ] Deepen modules (move complexity behind simple interfaces)
- [ ] Consider what new code reveals about existing code
- [ ] Run tests after each refactor step

**Never refactor while RED.** Get to GREEN first. After refactor, should still
be GREEN.

Tests should not change while refactoring the codebase, except where necessary
to align with a refactoring step (e.g. renamed function or added/removed parameter).

You can (and should) also refactor test code to improve readability and ergonomics for
writing/maintaining the tests, but do not change the main codebase during this step, and do not make changes to tests that make them less explicit/clear.

## Checklist Per Cycle

```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Code is minimal for this test
[ ] No speculative features added
```
