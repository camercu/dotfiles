# Spec Template

Output format for Step 4. Flat markdown, not a GitHub issue.

---

```markdown
# [Feature Name] — Specification

## Summary

One paragraph: what, why, for whom.

## Context

- Current state (from Step 0 codebase analysis)
- Problem being solved
- Key constraints and decisions from discovery

## Requirements

### Functional

- **REQ-001**: [Testable requirement statement]
- **REQ-002**: [Testable requirement statement]
- ...

### Non-Functional

- **REQ-NF-001**: [Performance / security / reliability requirement]
- ...

### Out of Scope

- Explicitly excluded items (from discovery boundaries)

## Design Notes

Architecture decisions, integration points, migration strategy. Reference `/improve-architecture` proposals if applicable.

## Open Questions

Unresolved items from red-teaming (if any).

## Acceptance Criteria

Map to requirements. Each criterion is a GIVEN-WHEN-THEN that can become a `/tdd` acceptance test.

- **AC-001** (REQ-001): GIVEN [context] WHEN [action] THEN [outcome]
- ...
```

---

## Numbering

- REQ-001..REQ-NNN for functional
- REQ-NF-001..REQ-NF-NNN for non-functional
- AC-001..AC-NNN for acceptance criteria, parenthetical maps to requirement

Numbers are stable — never renumber. Deleted requirements leave gaps.
