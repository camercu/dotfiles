# CONTEXT.md Format

## Structure

```markdown
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Order**:
A customer's request to purchase one or more items.
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

## Relationships

- An **Order** produces one or more **Invoices**
- An **Invoice** belongs to exactly one **Customer**

## Example dialogue

> **Dev:** "When a **Customer** places an **Order**, do we create the **Invoice** immediately?"
> **Domain expert:** "No — an **Invoice** is only generated once a **Fulfillment** is confirmed."

## Flagged ambiguities

- "account" was used to mean both **Customer** and **User** — resolved: these are distinct concepts.
```

## Rules

- **Be opinionated.** Multiple words for same concept → pick one, list others as _Avoid_.
- **Flag conflicts explicitly.** Ambiguous terms go in "Flagged ambiguities" with clear resolution.
- **Keep definitions tight.** One sentence max. Define what it IS, not what it does.
- **Show relationships.** Bold term names, express cardinality where obvious.
- **Domain terms only.** No general programming concepts (timeouts, error types, utility patterns). Ask: is this unique to this context, or a general concept?
- **Group terms** under subheadings when natural clusters emerge. Flat list is fine if all terms are cohesive.
- **Write an example dialogue.** Dev + domain expert conversation demonstrating how terms interact and clarifying boundaries.

## Single vs Multi-Context

**Single context (most repos):** One `CONTEXT.md` at repo root.

**Multiple contexts:** `CONTEXT-MAP.md` at repo root:

```markdown
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — receives and tracks customer orders
- [Billing](./src/billing/CONTEXT.md) — generates invoices and processes payments

## Relationships

- **Ordering → Billing**: Ordering emits `OrderPlaced` events; Billing consumes them
- **Ordering ↔ Billing**: Shared types for `CustomerId` and `Money`
```

Infer which structure applies:
- `CONTEXT-MAP.md` exists → read it to find contexts
- Only root `CONTEXT.md` → single context
- Neither → create root `CONTEXT.md` lazily when first term is resolved
