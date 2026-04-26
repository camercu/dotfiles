---
name: to-tasks
description: Break a plan or spec into vertical-slice tasks. Use when user wants to break down work into tasks, slice a spec into implementable pieces, or mentions "to-tasks", "break down", "task breakdown", or "slice".
---

# To Tasks

Break a plan or spec into independently-implementable **vertical slice** tasks.

## Input

Prefer a `/to-spec` output as input. Also works from conversation context, GitHub issues (`gh issue view`), or loose descriptions. If source is a GitHub issue, fetch with comments.

## Vertical Slices

Every task is a **tracer bullet** — a thin, end-to-end slice through ALL layers (schema, API, logic, UI, tests). Not a horizontal slice of one layer.

See [tracer-bullets.md](../tdd/tracer-bullets.md) for full rationale.

### Rules

- Each slice delivers a narrow but **complete path** through every integration layer
- A completed slice is **demoable or verifiable on its own** — if it can't be, it's too thin
- If a slice **takes more than one session to implement**, it's too thick — split it
- Prefer many thin slices over few thick ones
- **Task 1 is always the walking skeleton**: thinnest end-to-end path that proves the architecture works and is deployable. All subsequent tasks flesh out from this working core.

### Anti-Patterns

- "Set up the database schema" → horizontal slice, not demoable alone
- "Build the API layer" → horizontal, no end-to-end path
- "Implement everything for feature X" → too thick, multiple sessions

### Good Slices

- "User can create an account and see empty dashboard" → thin end-to-end
- "Single item flows through pipeline from ingest to output" → walking skeleton
- "Search returns results for exact match" → narrow but complete

## Process

### 1. Gather Context

Work from conversation context. If user passes a spec, GitHub issue, or URL — read it. Explore the codebase to understand integration layers, existing patterns, and boundaries. Can't slice what you don't know.

### 2. Draft Structure

Present a **lightweight numbered list** for user feedback. For each task:

- **Title**: short descriptive name
- **Type**: HITL (needs human input) / AFK (agent can implement alone)
- **Implements**: spec requirements covered (e.g. "2.1, 2.3") — omit if no spec
- **Blocked by**: which tasks must complete first (by number)

Number tasks in **suggested implementation order**: walking skeleton first, then by dependency chain. Prefer AFK over HITL.

Ask:
- Granularity right? (too coarse / too fine)
- Dependencies correct?
- HITL/AFK classifications correct?
- Any slices to merge or split?

Iterate until user approves structure.

### 3. Flesh Out

For each approved task, add:

- **What to build**: concise end-to-end behavior description, not layer-by-layer
- **Acceptance criteria**: observable behavior, not implementation details ("user sees confirmation" not "database has row"). GIVEN-WHEN-THEN where useful.

### 4. Output

Produce flat markdown task list:

```markdown
# [Feature/Spec Name] — Tasks

Source: [spec file or issue reference]

## Task 1: [Walking Skeleton Title] (AFK)

**Implements:** 1.1, 1.2
**Blocked by:** None — start here

[End-to-end behavior description]

### Acceptance Criteria

- [ ] [Observable behavior]
- [ ] [Observable behavior]

## Task 2: [Title] (AFK)

**Implements:** 2.1, 2.3
**Blocked by:** Task 1

...
```

Cross-refs: `/to-spec` (input), `/tdd` (each task → acceptance test).
