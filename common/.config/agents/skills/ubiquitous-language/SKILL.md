---
name: ubiquitous-language
description: Use when user wants to define domain terms, build a glossary, harden terminology, create a ubiquitous language, or mentions "DDD" or "event modeling". For batch extraction from the current conversation and codebase.
---

# Ubiquitous Language

## Overview

Extract and formalize domain terminology from the current conversation and codebase into `CONTEXT.md`. Nouns name the things; verbs (commands, events, processes) name the module and public-interface abstractions, so the glossary needs both.

Cross-ref: `/domain-model` for interactive plan-review grilling with inline updates. This skill is for batch extraction from conversation and codebase.

## Process

**Public surface** below = anything a user writes, runs, reads or depends on, at any stage: e.g. API, macros, CLI flags, exit codes, config and env vars, features, wire or file formats, compile errors. An item documented as internal is outside it, even when `pub`.

1. **Scan sources** for domain nouns, verbs and concepts, in this order: the conversation (if any), existing `CONTEXT.md`, specs, ADRs, README, user docs (man pages, `--help`), then the public surface.
2. **Event-model the domain** to surface the verbs. Split the model where the domain splits (its subdomains and their processes), not where the implementation does: a hotel-booking site splits into search, reservation and payment, not frontend, backend and database. Code structure counts only where it mirrors a real domain boundary, such as a protocol layer. Walk one real scenario per part as a timeline and list:
    - **Commands**: what a caller asks for, imperative.
    - **Events**: facts that happened, past tense: anything the code reports, emits or reacts to as having happened, whatever its form (e.g. an enum variant, a callback, an error, a compile error, an exit, an expired timeout).
    - **Views**: state a caller reads to decide.
    - **Automations**: rules where an event triggers a command.

    Map each command and event to its **standard name**, from the first source that has one: a formal standard for the operation (ISO, RFC, POSIX); a de facto reference the field treats as canonical (dominant implementation, textbook, man page); prior art the project cites or competes with; the dominant term in the field. Done when every public-surface entry point and every event maps to a row (related setters or flags may share one row), and every other public type maps to a term or is listed as unmapped.
3. **Identify problems**:
    - Same word used for different concepts (ambiguity)
    - Different words used for the same concept (synonyms)
    - Vague or overloaded terms
    - A command or event the code names with a noun or a different verb than the model
    - Behaviour that contradicts its name (a defect: report it with the term)
    - Two sources that describe the same thing differently (a defect in one of them)
    - A module or crate boundary that cuts across a domain split with no technical reason given
4. **Check every term, old and new, against four bars**: the standard name (step 2 order), clear, plain technical English, concise. A term that fails → propose the better one. A **settled** name (any public-surface name, a term defined in `CONTEXT.md` or an ADR, or one the user chose) → flag a rename as open, with evidence, instead of making it. Settling freezes the name only: fix a wrong or stale definition directly.
5. **Write `CONTEXT.md`** using the format below, with opinionated term choices. When it exists, merge: keep resolved flags and every fact; move a load-bearing invariant that does not fit one sentence (layout, formula, ordering rule) into Relationships, never drop it.
6. **Output a summary** to whoever invoked the skill (the user, or the calling agent), listing open flags as numbered questions with a recommendation each.

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

### {Domain part}

{One-line scenario walked.}

| Command | Events | Standard name | Code |
|---|---|---|---|
| Place an order | Order placed; order rejected | | `Orders::place`, `shop order place` |
| | Payment received | | `PaymentReceived` |
| | Order refused for bad input | sysexits `EX_DATAERR` | exit code 65 |

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
- "cart" and "basket" both name the **Order** draft — open: rename `Basket` to `Cart`? Recommend yes (dominant e-commerce term).
```

## Rules

- **Be opinionated.** Multiple words for same concept → pick one, list others as _Avoid_.
- **Flag conflicts explicitly.** Ambiguous terms go in "Flagged ambiguities" with clear resolution.
- **Keep definitions tight.** One sentence max. Define what it IS, not what it does; define a role by what it is responsible for. Facts beyond the sentence go to Relationships.
- **Name verbs by role.** Commands imperative, events past tense, one verb per action across all layers.
- **Show relationships.** Bold term names, express cardinality where obvious.
- **Domain terms only.** Include a term, module or class name only when a domain expert would use it.
- **Group terms** under subheadings when natural clusters emerge. Flat list fine if cohesive.
- **Write an example dialogue.** Dev + domain expert conversation (3-5 exchanges) demonstrating how terms interact and clarifying boundaries.

## Re-running

When `CONTEXT.md` already exists (this or an earlier conversation): read it first, add terms from new sources or discussion, re-flag new ambiguities, and write or rewrite the example dialogue to use the new terms. Step 5's merge rules apply.
