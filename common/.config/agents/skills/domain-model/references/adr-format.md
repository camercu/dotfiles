# ADR Format

ADRs live in `docs/adr/` with sequential numbering: `0001-slug.md`, `0002-slug.md`. Create directory lazily when first ADR needed. Scan for highest existing number and increment.

## Template

```markdown
# {Short title of the decision}

{1-3 sentences: what's the context, what did we decide, and why.}
```

That's it. An ADR can be a single paragraph. The value is recording *that* a decision was made and *why* — not filling out sections.

## Optional Sections

Only when they add genuine value. Most ADRs won't need them.

- **Status** frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`) — when decisions are revisited
- **Considered Options** — only when rejected alternatives are worth remembering
- **Consequences** — only when non-obvious downstream effects need calling out

## When to Create

ALL three must be true:

1. **Hard to reverse** — cost of changing your mind later is meaningful
2. **Surprising without context** — future reader will wonder "why on earth?"
3. **Real trade-off** — genuine alternatives existed, picked one for specific reasons

If easy to reverse → skip, you'll just reverse it. Not surprising → nobody will wonder. No real alternative → nothing to record beyond "we did the obvious thing."

## What Qualifies

- Architectural shape ("monorepo", "event-sourced write model")
- Integration patterns between contexts (events vs synchronous HTTP)
- Technology choices with lock-in (database, message bus, auth provider — not every library)
- Boundary and scope decisions ("Customer data owned by Customer context; others reference by ID only")
- Deliberate deviations from the obvious path (prevents someone "fixing" something deliberate)
- Constraints not visible in code (compliance, partner API contracts)
- Rejected alternatives when rejection is non-obvious
