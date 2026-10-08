---
name: ubiquitous-language
description: Use when user wants to define domain terms, build a glossary, harden terminology, create a ubiquitous language, or mentions "DDD" or "event modeling". For batch extraction from the current conversation and codebase.
---

# Ubiquitous Language

## Overview

Extract and formalize domain terminology from the current conversation and codebase into `CONTEXT.md`. Nouns name the things; verbs (commands, events, processes) name the module and public-interface abstractions, so the glossary needs both.

Cross-ref: `/domain-model` for interactive plan-review grilling with inline updates. This skill is for batch extraction from conversation and codebase.

## Process

1. **Scan sources** for domain nouns, verbs and concepts, in this order: the conversation (if any), existing `CONTEXT.md`, specs, ADRs and README, then the public API.
2. **Event-model the domain** to surface the verbs. Split by domain or layer only when the code has more than one. Walk one real scenario per part as a timeline and list:
    - **Commands**: what a caller asks for, imperative (`Send a request`).
    - **Events**: facts that happened, past tense (`Request sent`, `Timer expired`). Count as events whatever the code uses to report that something happened: event enums, callbacks and hooks, result or error variants, state transitions, external input arriving, timers expiring.
    - **Views**: state a caller reads to decide (`Outstanding request`).
    - **Automations**: rules where an event triggers a command (`Attempt failed → wait, then retry`).

    Map each command and event to its **standard name**: the governing standard, RFC or protocol if one exists (e.g. ISO service primitives `.req`/`.ind`/`.con`); else the prior-art libraries the project cites or competes with; else the dominant term in the field. Done when every public function and every event (as defined above) maps to a row, and every other public type maps to a term or is listed as unmapped.
3. **Identify problems**:
    - Same word used for different concepts (ambiguity)
    - Different words used for the same concept (synonyms)
    - Vague or overloaded terms
    - A command or event the code names with a noun or a different verb than the model
    - Behaviour that contradicts its name (a defect: report it with the term)
4. **Check every term, old and new, against four bars**: the standard name (step 2 order), clear, plain technical English, concise. A term that fails → propose the better one. A **settled** term (public API name, or defined in `CONTEXT.md` or an ADR, or chosen by the user) → flag it as open, with evidence, instead of changing it.
5. **Write `CONTEXT.md`** using the format below, with opinionated term choices.
6. **Output a summary** inline in the conversation, listing open flags as numbered questions with a recommendation each.

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

Views: **Open order** (`Orders::open`).
Automations: order placed → reserve stock.
Unmapped: `OrderRepo` (storage plumbing, no domain meaning).

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
- **Domain terms only.** Include a term, module or class name only when a domain expert would use it.
- **Group terms** under subheadings when natural clusters emerge. Flat list fine if cohesive.
- **Write an example dialogue.** Dev + domain expert conversation (3-5 exchanges) demonstrating how terms interact and clarifying boundaries.

## Re-running

When invoked again in the same conversation:

1. Read existing `CONTEXT.md`
2. Incorporate new terms from subsequent discussion
3. Update definitions if understanding has evolved
4. Re-flag any new ambiguities
5. Rewrite example dialogue to incorporate new terms
