---
name: ux-audit
description: Use when reviewing GUI or TUI usability, asked for a "Norman audit", "UX review", "usability check", "gulf of execution/evaluation", "error prevention check", or a "conceptual model" of an app. Runs from dogfood on GUI and TUI targets and from ux-design after a GUI or TUI change. Not for static web visual polish or accessibility conformance alone.
---

# UX audit

## Overview

Evaluate workflows against the design rules in `ux-design` and Norman's action cycle. Ground findings in the running interface and the code that determines its behavior. Produce a ranked findings report; implementation belongs to `ux-design` and `tdd`.

## Context

- **Design criteria.** Before auditing, read [ux-design](../ux-design/SKILL.md), specifically *Context*, *Plan*, and *Design rules*. The design rules are the shared source of truth. Apply approved project requirements and documented exceptions.
- **Scope.** For a change audit, inventory affected workflows; for a full audit, inventory all workflows. Reconcile acceptance tests, spec, README, and controls in the running app. Include undocumented workflows and identify documented goals without acceptance tests. Name each workflow as a verb phrase.
- **Controls and states.** Enumerate interactive controls, applicable observable states and combinations, and their availability and execution rules from the UI and core.
- **Live app.** Launch through the project's documented procedure or the `run` skill if available. Use an available GUI or terminal driver and the project's snapshot hook where available. Use disposable data and isolated environments for consequential probes.
- **Authority.** Use approved requirements for intended behavior, the running app for observed behavior, and code for causes and unexercised paths. Mark conflicts as findings.

## Steps

Open `.scratch/ux-audit/<run>/report.md` before step 1 and record evidence per `~/.config/agents/record-as-you-go.md`. Reuse existing verification evidence for the same revision, configuration, and workflow.

1. **Conceptual model.** Describe objects, relationships, actions, and lifecycle in the user's vocabulary. Compare the model communicated by the interface with the intended model, domain conventions, and available evidence of users' mental models. Record conflicting cues and unverified assumptions.
2. **Gulf of execution.** For each workflow, walk through goal, plan, specify, and perform. Record each step, the knowledge required, the cue or control available, and any gap. Include first-use discovery, alternate input paths, navigation, and frequent-task efficiency.
3. **Gulf of evaluation.** For each user action, walk through perceive, interpret, and compare. Record the observed feedback, its meaning, and whether it establishes the goal was achieved. Measure consequential response delays. Exercise stale, partial, failed, and uncertain outcomes where applicable.
4. **Error prevention and recovery.** Enumerate every applicable control and state pair, including disabled and hidden controls. Record the availability rule, expected and actual behavior, likely slips or mistakes, safeguards, and recovery path. Group equivalent pairs only when they share the same rules and outcome. Probe invalid inputs, interruptions, mode errors, and irreversible actions safely.
5. **Design-rule sweep.** For every workflow, account for every rule under `ux-design` *Design rules* in a coverage matrix. Link execution, evaluation, and prevention evidence already collected. Exercise remaining rules, including accessibility, visual hierarchy, consistency, user control, recognition, and trust. Record each rule as pass, finding, inapplicable with reason, or unverified with reason.
6. **Verify live.** Reproduce each finding where feasible and capture evidence. Walk each workflow using the keyboard, test focus and alternate supported input methods, and resize to the planned minimum and other relevant viewports. Use manual and automated accessibility checks and assistive technology where supported. Mark unavailable live checks unverified; code inspection alone cannot establish live behavior. Record existing representative-user evidence separately from agent walkthroughs and identify workflows where human validation remains outstanding.

## Report

Include context (app, revision, date, scope, driver), workflow inventory, conceptual model, execution tables, evaluation table, error-prevention table, design-rule coverage matrix, findings, and unverified checks.

Each finding includes severity (`blocker`, `high`, `medium`, or `low`), lens (`model`, `execution`, `evaluation`, `prevention`, or `design`), applicable design rule, expected and actual behavior, user impact, evidence (reproduction steps, code location and live capture where applicable), proposed fix, and status (`verified` or `unverified` with reason). Use measurements or traces for timing, semantic accessibility, and state transitions.

## Done criterion

Done when:

1. Every inventoried workflow has an execution table and every user action has an evaluation row.
2. Every applicable control and state pair has a prevention row or a reference to its equivalent group.
3. Every workflow has a coverage entry for every design rule and an account of applicable live and accessibility checks.
4. Every finding has evidence and a status; every unverified check has a reason. Human validation evidence and gaps are distinct from automated or agent-led checks.
5. The chat reply gives the report path, findings count by severity, and unverified coverage.

## Self-check

1. Compare the inventory with acceptance tests, specs, docs, and live controls. Every in-scope workflow has a row in the coverage matrix.
2. Match workflow steps and actions to the execution and evaluation tables. Every action has an entry or a reference.
3. Match every applicable control and state pair to the prevention table. Every availability rule, including disabled and hidden cases, is accounted for.
4. Compare the design-rule headings in `ux-design` with the matrix for each workflow. Every rule has a disposition.
5. Inspect live captures, measurements, and accessibility results. Every verified claim has evidence; every unavailable check has a reason.
6. Match the final findings, unverified checks, and severity totals to the report. Report actual results; leave human usability validation unverified where representative users have yet to evaluate the workflow.
