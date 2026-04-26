---
name: ubiquitous-language
description: Extract a DDD-style ubiquitous language glossary from the current conversation into CONTEXT.md. Use when user wants to define domain terms, build a glossary, harden terminology, create a ubiquitous language, or mentions "domain model" or "DDD".
---

# Ubiquitous Language

Extract and formalize domain terminology from the current conversation into `CONTEXT.md`.

Cross-ref: `/domain-model` for interactive plan-review grilling with inline updates. This skill is for batch extraction from conversation.

## Process

1. **Scan the conversation** for domain-relevant nouns, verbs, and concepts
2. **Identify problems**:
    - Same word used for different concepts (ambiguity)
    - Different words used for the same concept (synonyms)
    - Vague or overloaded terms
3. **Propose a canonical glossary** with opinionated term choices
4. **Write to `CONTEXT.md`** using the format below
5. **Output a summary** inline in the conversation

## Output Format

Write `CONTEXT.md` at repo root (or per-context if `CONTEXT-MAP.md` exists):

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
> **Domain expert:** "No — an **Invoice** is only generated once a **Fulfillment** is confirmed. A single **Order** can produce multiple **Invoices** if items ship in separate **Shipments**."
> **Dev:** "So if a **Shipment** is cancelled before dispatch, no **Invoice** exists for it?"
> **Domain expert:** "Exactly. The **Invoice** lifecycle is tied to the **Fulfillment**, not the **Order**."

## Flagged ambiguities

- "account" was used to mean both **Customer** and **User** — resolved: these are distinct concepts.
```

## Rules

- **Be opinionated.** Multiple words for same concept → pick one, list others as _Avoid_.
- **Flag conflicts explicitly.** Ambiguous terms go in "Flagged ambiguities" with clear resolution.
- **Keep definitions tight.** One sentence max. Define what it IS, not what it does.
- **Show relationships.** Bold term names, express cardinality where obvious.
- **Domain terms only.** No general programming concepts. Don't glossary-ify module or class names unless they have meaning to domain experts. Ask: would a domain expert use this term?
- **Group terms** under subheadings when natural clusters emerge. Flat list fine if cohesive.
- **Write an example dialogue.** Dev + domain expert conversation (3-5 exchanges) demonstrating how terms interact and clarifying boundaries.

## Re-running

When invoked again in the same conversation:

1. Read existing `CONTEXT.md`
2. Incorporate new terms from subsequent discussion
3. Update definitions if understanding has evolved
4. Re-flag any new ambiguities
5. Rewrite example dialogue to incorporate new terms
