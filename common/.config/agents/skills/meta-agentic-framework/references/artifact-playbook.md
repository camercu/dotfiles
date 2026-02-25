# artifact playbook

This playbook defines how to use `.meta-framework/` artifacts consistently.

## PROJECT.md

Write once at project start, then update only when scope changes:

- Problem statement
- Target users
- Constraints
- Non-goals
- Success criteria

## REQUIREMENTS.md

Track approved product requirements. Use stable identifiers for references in
spec and plans.

## ROADMAP.md

Track milestones and phase ordering. Update when priorities change.

## STATE.md

Update after each work session and each execution wave:

- Current phase and wave
- Completed tasks
- In-progress tasks
- Blockers
- Next actions

## DECISIONS.md

Capture key decisions with date, context, decision, and consequences.

## phases/<phase-id>/CONTEXT.md

Store the minimal context needed to execute the phase:

- Scope
- Dependencies
- Known risks
- Inputs and outputs

## phases/<phase-id>/RESEARCH.md

Store primary-source findings and contradictions discovered during research.
Include date and links for each finding.

## phases/<phase-id>/SPEC.md

Store the approved portable spec. Follow nested-numbered requirements.

## phases/<phase-id>/PLAN.md

Store atomic tasks with dependencies, touched files, and verification command.

## phases/<phase-id>/SUMMARY.md

Summarize what shipped, what changed, and what remains deferred.

## phases/<phase-id>/VERIFICATION.md

Record concrete evidence:

- Commands run
- Test results
- Manual validation outcomes
- Requirement coverage mapping
