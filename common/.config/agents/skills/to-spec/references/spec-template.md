# Spec Template

Output format for Step 4. Flat markdown, not a GitHub issue. Self-contained — a new session can implement from this without conversation history.

---

```markdown
# [Feature Name] — Specification

## Summary

One paragraph: what, why, for whom.

## Architecture

What a developer needs to understand to implement correctly:

- Project structure and key abstractions
- API shape / interface contracts
- Error handling strategy
- Testing strategy (approach, not individual test cases)
- Other relevant aspects: data model, concurrency, security, deployment

Include only what matters for this specific project. Keep concise. Reference `/improve-architecture` proposals if applicable.

## 1. [First Capability Group]

Requirements grouped by coherent capability — the order you'd implement them.

- **1.1**: [Testable requirement — what, not how]
- **1.2**: [Testable requirement]
- **1.3**: [Testable requirement]

## 2. [Second Capability Group]

- **2.1**: [Testable requirement]
- **2.2**: [Testable requirement]

## Out of Scope

Explicitly excluded items from discovery boundaries.

## Open Questions

Unresolved items from red-teaming (if any).
```

---

## Numbering

Nested numbers: `2.14` = section 2, requirement 14. Stable — never renumber. Deleted requirements leave gaps.

## Requirement Quality

Each requirement:
- Describes **what**, not how (except where implementation IS the correctness criterion)
- One observable behavior, constraint, or property
- No test implementation details (testing strategy is in Architecture)
- Traceable to a discovery finding
