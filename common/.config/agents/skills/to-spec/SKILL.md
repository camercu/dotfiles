---
name: to-spec
description: Use when user wants to write a spec, refine requirements, design a feature, or mentions "spec", "requirements", "PRD", "specification".
---

# Specification Refinement

## Overview

Collaborative process: analyze codebase → interview for shared understanding → draft & red-team iteratively → produce numbered-requirement spec.

## Role

You are an **independent technical collaborator**, not a transcriber. Research and verify user claims. Push back with evidence when the user proposes something incorrect — their certainty is not evidence, and neither is yours. When uncertain, research before asserting. User owns the final decision.

Adapt this process to the project. Skip steps that add no value. Propose process changes when something is causing friction.

## Context Loading

| When | Load |
|------|------|
| Step 2 — Discovery | `discovery-questions.md` |
| Step 3 — Draft & Refine | `red-team-checklist.md` |
| Step 4 — Write spec | `spec-template.md` |

## When to Compress

| Situation | Skip to |
|-----------|---------|
| Small, well-defined change | Use existing acceptance criteria. Write Step 4 only when a spec was requested or the handoff needs one. |
| Well-understood pattern ("done this before") | Step 2 (brief) → Step 4 |
| Pure refactor, no behavior change | Skip entirely — use `/improve-architecture` |
| Greenfield, no existing code | Skip Step 0 |
| Prototype / spike | Step 2 (brief) → Step 4, mark spec as "draft" |

When a formal spec is justified, keep Step 4's numbered, testable requirements.
Use established project decisions as defaults. Interview only when remaining
uncertainty could change implementation, acceptance, or migration.

## Process

### 0. Codebase Analysis

Explore relevant code, tests, docs, ADRs. Understand current architecture, constraints, existing patterns. Note integration points, test coverage, and conventions. Scope to modules the feature touches. Cross-ref `/improve-architecture` for architectural context.

Skip when greenfield.

### 1. Research

Gather domain knowledge: docs, prior art, relevant standards, existing implementations. Use primary sources. Share findings with user for correction. Surface contradictions between research and user assumptions explicitly.

Skip when domain well-understood or pure bug fix.

### 2. Discovery Interview

**Goal: complete map of the problem, not a plan for solving it.** Do not design solutions during discovery.

Identify the consumer's primary workflow. Justify features, options, and
abstractions by how they support it. Prefer a smaller coherent workflow when
added capabilities would make ordinary use harder.

For consequential open questions, use `/grill-me` with codebase evidence and a
recommended answer. Stop when remaining uncertainty will not materially change
implementation. Record assumptions and explicitly deferred decisions.

Load [discovery-questions.md](references/discovery-questions.md) for domain-specific prompts.

### 3. Draft & Refine Loop

Produce initial architecture + development plan. Then iterate:

1. **Walk the design tree** — for every open decision, present recommended choice with rationale and trade-offs. Resolve dependencies between decisions explicitly.
2. **Red-team** — Does every abstraction earn its keep? Bugs, conflicts, ambiguities? Architecture proportionate to problem? Testing strategy actually workable? Load [red-team-checklist.md](references/red-team-checklist.md).
3. **Simplify** — each pass should reduce or hold steady on complexity while improving precision and coverage.

Use one focused red-team pass when the design warrants it. Repeat on affected
decisions only when consequential ambiguity or a new contract risk remains.

### 4. Write Spec

Produce flat markdown spec. Use [spec-template.md](references/spec-template.md).

Requirements are **nested-numbered** (e.g. 2.14) for unambiguous reference. Each requirement:
- Describes **what**, not how — except where implementation approach IS the correctness criterion
- Testable (can write acceptance test for it)
- Independent (no implicit ordering)
- Necessary (traced to discovery finding)

Do not include test implementation details in requirements. Testing strategy belongs in the architecture section.

### 5. User Review

User approves, requests changes, or sends back to Step 3 for more cycles.

## Principles

**Complexity must be justified by the problem, not by methodology.** Every abstraction, indirection, or infrastructure component must exist because the problem demands it.

**Error injection should be proportionate.** Most errors are testable by creating real failure conditions. Build injection only for genuinely hard-to-trigger errors, with narrowest mechanism.

**The spec is the portable artifact.** Write it so a new session can load the spec and begin implementation without the conversation history. Summarize key design decisions and rationale in the architecture section.

**Process overhead is accidental complexity too.** Formal schemas, dependency graphs, fine-grained tracking — use only when scale or regulatory requirements demand them.
