---
name: ubiquitous-language
description: Use when user wants to define domain terms, build a glossary, harden terminology, create a ubiquitous language, or mentions "DDD" or "event modeling". For batch extraction from the current conversation and codebase.
---

# Ubiquitous Language

## Overview

Extract and formalize domain terminology from the current conversation and codebase into `CONTEXT.md`. Nouns name the things; verbs (commands, events, processes) name the module and public-interface abstractions, so the glossary needs both.

Cross-ref: `/domain-model` for interactive plan-review grilling with inline updates. This skill is for batch extraction from conversation.

## Process

1. **Scan the conversation, code and specs** for domain nouns, verbs and concepts.
2. **Event-model each domain or layer** to surface the verbs. Per domain, walk one real scenario as a timeline and list:
    - **Commands**: what a caller asks for, imperative (`Send a request`).
    - **Events**: facts that happened, past tense (`Request sent`, `Timer expired`), including external events arriving and timers expiring.
    - **Views**: state a caller reads to decide (`Outstanding request`).
    - **Automations**: rules where an event triggers a command (`Response pending received → wait P2*`).

    Map each command and event to the standard's own name where one exists (ISO service primitives `.req`/`.ind`/`.con`, RFC verbs, protocol state names). Done when every public function and event type in the code maps to a row, or is flagged as unmapped.
3. **Identify problems**:
    - Same word used for different concepts (ambiguity)
    - Different words used for the same concept (synonyms)
    - Vague or overloaded terms
    - A command or event the code names with a noun or a different verb than the model
4. **Check every term, old and new, against four bars**: the standard or established-practice term (unsurprising to an expert), clear, plain technical English, concise. A term that fails → propose the better one; a term the user settled earlier → flag it as open, with evidence, instead of changing it.
5. **Propose a canonical glossary** with opinionated term choices
6. **Write to `CONTEXT.md`** using the format below
7. **Output a summary** inline in the conversation, listing open flags as numbered questions with a recommendation each

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

## Event model

| Command | Events | Standard name | Code |
|---|---|---|---|
| Place an order | Order placed; order rejected | | `Orders::place` |
| | Payment received | | `PaymentReceived` |

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
- **Name verbs by role.** Commands imperative, events past tense, one verb per action across all layers.
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
