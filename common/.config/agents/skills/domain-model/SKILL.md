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

## Setup

Find existing documentation:

- **Single context**: `CONTEXT.md` at repo root, `docs/adr/` for decisions
- **Multi-context**: `CONTEXT-MAP.md` at root points to per-context `CONTEXT.md` files
- **Neither exists**: create lazily when first term is resolved or first ADR needed

If `CONTEXT-MAP.md` exists, infer which context the current topic relates to. If unclear, ask.

Cross-ref: `/improve-architecture` for structural analysis, `/ubiquitous-language` for batch glossary extraction.

## During the Session

Interview relentlessly — one question at a time. For each question, provide recommended answer. If a question can be answered by exploring the codebase, explore instead of asking.

### Challenge against the glossary

When user uses a term that conflicts with `CONTEXT.md`, call it out immediately. _"Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"_

### Sharpen fuzzy language

When user uses vague or overloaded terms, propose a precise canonical term. _"You're saying 'account' — do you mean the Customer or the User? Those are different things."_

### Discuss concrete scenarios

Stress-test domain relationships with specific scenarios. Invent edge cases that force precision about boundaries between concepts.

### Cross-reference with code

When user states how something works, check whether the code agrees. Surface contradictions: _"Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"_

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` immediately — don't batch. Use [context-format.md](references/context-format.md). Only include terms meaningful to domain experts, not implementation details.

### Offer ADRs sparingly

Only when ALL three are true:

1. **Hard to reverse** — cost of changing your mind later is meaningful
2. **Surprising without context** — future reader will wonder "why?"
3. **Real trade-off** — genuine alternatives existed, you picked one for specific reasons

If any is missing, skip. Use [adr-format.md](references/adr-format.md).
