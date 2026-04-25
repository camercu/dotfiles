---
name: spec-refinement
description: Collaborative specification refinement through codebase analysis, discovery interviews, and iterative red-teaming. Use when user wants to write a spec, refine requirements, design a feature, or mentions "spec", "requirements", "PRD", or "specification".
---

# Specification Refinement

Collaborative process: analyze codebase → interview for shared understanding → red-team iteratively → produce numbered-requirement spec.

## Context Loading

| When | Load |
|------|------|
| Step 2 — Discovery | `discovery-questions.md` |
| Step 3 — Red-team | `red-team-checklist.md` |
| Step 4 — Write spec | `spec-template.md` |

## When to Compress

Not every change needs full process. Scale to fit:

| Situation | Skip to |
|-----------|---------|
| Trivial (rename, config, small bug) | Step 4 — write spec directly |
| Well-understood pattern ("done this before") | Step 2 (brief) → Step 4 |
| Pure refactor, no behavior change | Skip entirely — use `/improve-architecture` |
| Greenfield, no existing code | Skip Step 0 |
| Prototype / spike | Step 2 (brief) → Step 4, mark spec as "draft" |

**Never skip**: Step 2 (discovery) and Step 4 (numbered requirements). Discovery prevents building wrong thing. Numbered requirements prevent ambiguity.

## Process

### 0. Codebase Analysis

Explore relevant code, tests, docs, ADRs. Understand current architecture, constraints, existing patterns. Note integration points, test coverage, and conventions.

If codebase is large, scope to modules the feature touches. Cross-ref `/improve-architecture` for architectural context.

Skip when greenfield.

### 1. Research

Gather domain knowledge needed to have informed discovery conversation. Read docs, prior art, relevant standards, existing implementations in codebase.

Skip when domain well-understood or pure bug fix.

### 2. Discovery Interview

**Goal: shared understanding.** Grill user (see `/grill-me`) on:

- What problem does this solve? For whom?
- What does success look like? How measured?
- What are the boundaries? What's explicitly out of scope?
- What are the constraints (technical, timeline, compliance)?
- What existing behavior must be preserved?

Keep asking until no ambiguity remains. For each question, offer recommended answer based on codebase analysis and research. Challenge assumptions — "why not X instead?"

Load [discovery-questions.md](references/discovery-questions.md) for domain-specific prompts.

### 3. Red-Team

Iterative stress-testing. For each round:

1. Present attack vectors: edge cases, failure modes, security concerns, scalability issues, UX problems, integration conflicts
2. User responds — accept, reject, modify
3. Update understanding, repeat

Load [red-team-checklist.md](references/red-team-checklist.md) for systematic coverage.

Stop when: no new issues found for a full round, or user calls it.

### 4. Write Spec

Produce flat markdown spec. Use [spec-template.md](references/spec-template.md).

**Requirements are numbered** (REQ-001, REQ-002, ...) for unambiguous reference in implementation, tests, and reviews. Each requirement is:
- Testable (can write acceptance test for it)
- Independent (no implicit ordering)
- Necessary (traced to discovery finding)

### 5. User Review

User approves, requests changes, or sends back to Step 3 for more red-teaming.
