---
name: improve-codebase-architecture
description: Surface architectural friction, propose deepening opportunities. Use when user wants to clean up or improve the codebase architecture or design.
---

# Improve Codebase Architecture

Surface friction, propose **deepening opportunities** — refactors that increase depth, cohesion, locality while reducing coupling.

## Context Loading

Load references **progressively** — only when entering the phase that needs them. Do not front-load all references at skill activation.

| When | Load |
|------|------|
| Skill activation | `LANGUAGE.md` (vocabulary for all phases) |
| Step 1 — Explore | `ANTI-PATTERNS.md` |
| Step 1b — Evidence | `EVIDENCE.md` |
| Step 3 — Grill | `PATTERN-GUIDE.md`, `DEEPENING.md` |
| Step 4 — Design | `INTERFACE-DESIGN.md` |
| Step 6 — Proposal | `PROPOSAL-TEMPLATE.md` |

If user jumps directly to a step, load that step's references + all prior unloaded ones.

## Language & Context

Terms in [references/LANGUAGE.md](references/LANGUAGE.md). Use exactly — no "service," "component," "controller," "boundary."

Read `CONTEXT.md` + `docs/adr/` before exploring. Proceed silently if absent.

Core principles: **deletion test** (delete module → complexity vanishes = pass-through, reappears across callers = earning keep). **Interface = test surface.** **One adapter = hypothetical seam; two = real.** **Deep = testable at boundary.**

## Guardrails

**Scale**: <5k LOC → lightweight, skip sub-agents. 5k–50k → full process. >50k → scope to one context per session.

**Skip when**: <5 commits/6mo, 1–2 callers, scheduled for deletion, no test pain, deadline pressure. Note skip reason for future reviews. DO NOT SKIP IF USER EXPLICITLY ASKS FOR REVIEW OF THAT SEAM.

## Process

### 1. Explore

Navigate organically. Note: shallow modules, scattered understanding, coupling leaks, untestable interfaces. Flag hot paths and concurrency boundaries.

Apply **deletion test** to suspect modules. Check [references/ANTI-PATTERNS.md](references/ANTI-PATTERNS.md).

### 1b. Gather evidence

Collect quantitative signals before presenting candidates. Details + commands in [references/EVIDENCE.md](references/EVIDENCE.md):

- Git hotspots + co-change coupling
- Fan-in / fan-out per module
- Test coverage gaps
- Churn x complexity

Gather what's practical — not every signal available in every project.

### 2. Present candidates

Numbered list, **ranked by priority** (impact + risk). Per candidate:

- **Files** — modules involved
- **Problem** — friction type (cohesion/coupling/depth/locality) + anti-pattern if applicable
- **Solution + Benefits** — what changes, gains in locality/leverage/testability
- **Priority** — Impact / Risk / Effort (H/M/L)
- **Evidence** — from Step 1b

Use `CONTEXT.md` domain language. Flag ADR contradictions only when friction is real. Do NOT propose interfaces — ask which to explore.

### 3. Grill

Walk design tree: interface constraints, dependencies, hidden complexity, test strategy ([references/PATTERN-GUIDE.md](references/PATTERN-GUIDE.md), [references/DEEPENING.md](references/DEEPENING.md)).

Side effects: new concept → add to `CONTEXT.md`. Sharpened term → update `CONTEXT.md`. Load-bearing rejection → offer ADR (see `/domain-model` for CONTEXT.md and ADR formats, three-gate ADR check).

### 4. Design interfaces

Simple → propose one interface from grilling constraints.
Ambiguous/Complex → parallel sub-agents (see [references/INTERFACE-DESIGN.md](references/INTERFACE-DESIGN.md)).

### 5. User picks interface

### 6. Present proposal

Use template in [references/PROPOSAL-TEMPLATE.md](references/PROPOSAL-TEMPLATE.md): Problem, Proposed Interface, Architecture Decisions, Testing Strategy, Migration Plan (branch by abstraction/strangler fig → migrate callers → deepen → clean up), Implementation Recommendations.

### 7. Verify

After implementation: re-run deletion test, compare test counts (fewer at tighter interface = success), check fan-in/fan-out delta, spot-check locality (fewer files per change).

Marginal improvement = data for future sessions, not failure.

For code-level cleanup after architectural changes, run `/simplify`.
