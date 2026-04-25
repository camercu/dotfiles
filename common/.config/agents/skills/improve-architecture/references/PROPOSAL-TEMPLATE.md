# Proposal Template

Present the final deepening proposal using this structure. Each section required.

---

## Problem

- Which modules are shallow, tightly coupled, or hard to test
- What integration risk exists at their seams
- Why this makes the codebase harder to navigate and maintain

## Proposed Interface

- Interface signature (types, methods, params)
- Usage example showing most common caller
- Complexity it hides internally

## Architecture Decisions

- Cohesion improvements
- Coupling reductions
- New or eliminated abstraction boundaries

## Testing Strategy

- What the new module makes easier to test
- Which techniques to use (from [PATTERN-GUIDE.md](PATTERN-GUIDE.md))
- What existing tests to replace vs adapt

## Migration Plan

For simple changes, just do one-shot edit. For complex changes, use
expand-contract / branch by abstraction / strangler fig pattern:

- **Phase 1 — Adapter**: introduce new interface alongside old code. Old callers untouched. New interface delegates to existing implementation (branch by abstraction / strangler fig).
- **Phase 2 — Migrate callers**: move callers one at a time. Each migration = standalone commit/PR. Feature flags if risky.
- **Phase 3 — Deepen**: all callers on new interface → move implementation details behind it. Delete old shallow modules.
- **Phase 4 — Clean up**: remove temporary adapters, feature flags, compatibility shims.
- **Rollback strategy**: at each phase, describe how to revert without data loss or broken callers.

## Implementation Recommendations

- What the module should own (responsibilities)
- What it should hide (implementation details)
- What it should expose (interface contract)
