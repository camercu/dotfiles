---
name: domain-model
description: Stress-test a plan against the project's domain model. Challenges terminology, cross-references code, updates CONTEXT.md and ADRs inline. Use when user wants to validate a plan against domain language, sharpen terminology, or mentions "domain model".
---

# Domain Model

Grilling session that challenges a plan against the project's existing domain language and documented decisions. Updates documentation inline as decisions crystallize.

## Context Loading

| When | Load |
|------|------|
| Skill activation | Read `CONTEXT.md` + `docs/adr/` |
| Term resolved | `context-format.md` |
| ADR needed | `adr-format.md` |

## Input

Work from whatever plan is in conversation context — `/to-spec` output, GitHub issue, architecture proposal, or loose description. If no plan exists, ask user what to grill.

## Setup

Find existing documentation. See [context-format.md](references/context-format.md) for single-context vs multi-context structure. Create files lazily — only when first term resolved or first ADR needed.

Cross-ref: `/improve-architecture` for structural analysis, `/ubiquitous-language` for batch glossary extraction.

Then begin grilling.

## During the Session

Interview relentlessly — one question at a time. For each question, provide recommended answer. If a question can be answered by exploring the codebase, explore instead of asking.

### Challenge against the glossary

When user uses a term that conflicts with `CONTEXT.md`, call it out immediately. _"Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"_

Also surface **glossary-vs-code drift**: if `CONTEXT.md` says "Order" means X but code uses it as Y, that's a finding — one of them is wrong.

### Sharpen fuzzy language

When user uses vague or overloaded terms, propose a precise canonical term. _"You're saying 'account' — do you mean the Customer or the User? Those are different things."_

### Discuss concrete scenarios

Stress-test domain relationships with specific scenarios. Invent edge cases that force precision about boundaries between concepts.

### Cross-reference with code

When user states how something works, check whether the code agrees. Surface contradictions: _"Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"_

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` immediately — don't batch. Use [context-format.md](references/context-format.md). Only include terms meaningful to domain experts, not implementation details.

### Offer ADRs sparingly

Only when the decision passes the three-gate check. See [adr-format.md](references/adr-format.md) for criteria and format.

## When to Stop

All terms in the plan are sharp, no glossary conflicts remain, code-vs-plan contradictions are resolved or explicitly accepted. If new ambiguity surfaces, keep going.
