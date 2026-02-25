---
name: meta-agentic-framework
description: State-driven meta-prompting framework for agentic software delivery. Combines design-first rigor, spec refinement loops, phased planning artifacts, wave-based execution, and strict verification gates. Use when a user asks to design, run, or customize an AI coding workflow/framework, create implementation specs for coding agents, or execute multi-phase software work with durable context and quality controls.
---

# Meta agentic framework

## Overview

Use this framework to run complex software delivery with strong quality
discipline and durable state across sessions. It synthesizes a
design-first approach, adversarial review, TDD-first implementation, and
phase artifacts that keep context portable.

Start by selecting a depth mode for process overhead:

- `quick`: Minimal artifacts, still requires an approved spec and
  verification.
- `standard`: Full workflow with one red-team pass per design cycle.
- `comprehensive`: Full workflow plus explicit risk register and two
  red-team passes before implementation.

## Artifact system

Use a portable artifact set rooted at `.meta-framework/`:

- `PROJECT.md`: Problem statement, users, constraints, non-goals.
- `REQUIREMENTS.md`: Accepted product requirements.
- `ROADMAP.md`: Milestones and phase sequencing.
- `STATE.md`: Current phase, task state, decisions, blockers.
- `DECISIONS.md`: ADR-style design decisions and rationale.
- `phases/<phase-id>/CONTEXT.md`: Scoped phase context.
- `phases/<phase-id>/RESEARCH.md`: Evidence and source-backed findings.
- `phases/<phase-id>/SPEC.md`: Approved portable specification.
- `phases/<phase-id>/PLAN.md`: Atomic implementation plan.
- `phases/<phase-id>/SUMMARY.md`: Outcome and deltas.
- `phases/<phase-id>/VERIFICATION.md`: Test and acceptance evidence.

If the project has no artifacts yet, run:

```bash
scripts/bootstrap_framework.sh /path/to/project phase-001
```

## Workflow

Follow these stages in order unless the user requests a justified deviation.

### 1) Intake and scoping

Clarify:

1. Problem, users, and success criteria.
2. Constraints, standards, and interoperability requirements.
3. Explicit out-of-scope boundaries.
4. Preferred methodology and tolerance for process overhead.

Record this in `PROJECT.md` and `REQUIREMENTS.md`.

### 2) Evidence and contradiction check

Research relevant standards, prior art, and existing systems before
designing. Prefer primary sources. If user assumptions conflict with
evidence, surface the contradiction with sources and propose alternatives.
The user owns the final decision.

Record findings in `phases/<phase-id>/RESEARCH.md`.

### 3) Approved design development

This stage incorporates a strict specification refinement loop:

1. Draft architecture and iteration plan.
2. Review with the user.
3. Integrate feedback and domain preferences.
4. Red-team the design:
   - Does each abstraction earn its keep?
   - Are there contradictions, ambiguities, or hidden coupling?
   - Is testing feasible as described?
   - Is plan granularity appropriate?
5. Simplify while improving correctness and clarity.

Repeat until issues are minor, typically two to four loops.

#### Rules for specification quality

- Do not design before problem understanding and research are complete.
- Keep complexity proportionate to the problem.
- Treat process overhead as accidental complexity.
- Add error-injection mechanisms only for failures that are genuinely hard
  to trigger in tests.
- Keep the spec portable for fresh-session handoff.

Specification format requirements:

- Flat markdown document.
- Architecture section first.
- Iteration sections grouped by coherent capability.
- Nested numbered requirements (`2.14`, `3.2`, and so on) for precise
  references.
- Requirements state observable behavior and constraints, not test
  implementation details.

Use `references/specification-template.md` for structure.

### 4) Planning and decomposition

Convert approved requirements into atomic tasks in
`phases/<phase-id>/PLAN.md`.

Task quality bar:

- One observable outcome per task.
- Clear file touch list.
- Explicit verification command(s).
- Dependency mapping for wave execution.
- Rollback or mitigation note for risky changes.

### 5) Execution in dependency waves

Execute tasks in waves where tasks in a wave are independent:

1. Run all ready tasks in parallel where safe.
2. Merge results and resolve integration conflicts.
3. Update `STATE.md`.
4. Start next wave.

For non-trivial tasks, enforce TDD order:

1. Write failing test for expected behavior.
2. Implement minimal change to pass.
3. Refactor while preserving passing tests.

### 6) Review gates

Before a task is complete, run two checks:

1. Spec compliance review: Does behavior match requirements exactly?
2. Code quality review: Bugs, regressions, maintainability, and missing
   tests.

Use `references/review-checklists.md`.

### 7) Verification and close-out

A phase is complete only when:

1. Verification evidence is captured in `VERIFICATION.md`.
2. The summary documents delivered scope and deferred items.
3. Roadmap and state artifacts are updated.

If acceptance criteria fail, return to planning with explicit deltas.

## Operating principles

- Independent collaborator, not a transcriber.
- Evidence over confidence.
- User decisions are final after tradeoffs are made explicit.
- Prefer another adversarial review pass over adding new process layers.
- Optimize for correctness first, then speed.

## References

- `references/specification-template.md`: Portable spec template with
  nested-numbered requirement scaffolding.
- `references/review-checklists.md`: Red-team, spec compliance, and code
  quality checklists.
- `references/artifact-playbook.md`: How and when to update each artifact.
