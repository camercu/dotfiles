---
name: ux-audit
description: Use when reviewing how usable a GUI or TUI workflow is, asked for a "Norman audit", "UX review", "usability check", "gulf of execution/evaluation", "error prevention check", or a "conceptual model" of an app. Runs from dogfood on every GUI/TUI target and from ux-design at the end of a GUI/TUI change. Not for web visual polish or accessibility conformance alone.
---

# UX audit

## Overview

A Norman audit of every workflow a GUI or TUI offers: the conceptual model,
the Gulf of Execution, the Gulf of Evaluation, and error prevention. Each claim
rests on two sources: the code that decides what a control shows, and the
running app. The output is a ranked findings file. This skill reports
problems and proposes constraints. Fixes go to `ux-design` or `tdd`.

## Context

- **Workflows.** Source in this order: acceptance tests (ATDD scenarios,
  e2e specs), then the spec's workflow or scope list, then the README. Each
  workflow is a user goal stated as a verb phrase ("find a burst and slice it
  out"). A goal the docs name with no acceptance test is itself a finding.
- **Controls and their conditions.** Grep the UI layer for each widget and
  read the condition that hides, disables or shows it. egui: `add_enabled`,
  `button(`, `selectable_label`. ratatui: the key handler `match`. Web: the
  `disabled=` and `hidden` bindings.
- **Live app.** Launch it through the `run` skill. Drive a GUI with the
  computer-use `app_*` tools, a TUI with `tmux send-keys` and
  `tmux capture-pane -p`. Use the project's snapshot hook (an env var or
  test backend that dumps a frame) when it has one.
- **Authority.** Live behavior beats code reading, and code reading beats docs.

## Steps

Open `.scratch/ux-audit/<run>/report.md` before step 1 and fill it as you go,
per `~/.config/agents/record-as-you-go.md`.

1. **Conceptual model.** Write three sentences from the user's view. Use no
   type, struct or module names, only what the user sees and does. Then list
   each place the screen suggests a different model, for example a control
   that looks like it does X but does Y.
2. **Gulf of Execution**, one table per workflow: step | signifier the user
   follows (a visible control, label, hint or cursor change) | problem. A
   problem is any of these: no signifier (a gesture only the docs reveal), a
   modifier key or shortcut with no visible hint, a control shown only after
   an earlier step, a control placed far from what it acts on, two controls
   that look alike, or one setting reached by two unlabeled controls.
3. **Gulf of Evaluation**, one row per user action: action | what on screen
   proves the app took it and shows the state now | gap. Check the in-flight
   state between an action and its result, a failure, a silent no-op, and a
   pane whose content changed meaning without a label saying so.
4. **Error prevention.** Enumerate the app's states: empty (nothing open),
   loading, ready, busy (a job or write in flight), failed. For every enabled
   control in every state, record what a click or keypress does now. A no-op
   or error row gets a constraint: disable it with the reason as a tooltip or
   hint, hide it, or confirm before running it. Mark a control that is
   enabled on purpose and harmless (a setting kept for later) as "keep",
   with the reason.
5. **Verify live.** Reproduce each step 2–4 finding in the running app and
   attach the screenshot or captured pane path. A finding you could not
   reproduce live is marked `unverified` with the reason (no display, the
   gesture can't be simulated).

## Report

Sections in order: context (app, commit, date, how it was driven),
conceptual model, execution tables, evaluation table, error-prevention
table, findings. Each finding has a severity (blocker/high/medium/low), a
lens (`model` | `execution` | `evaluation` | `prevention`), evidence
(`file:line` plus a screenshot path), a proposed fix, and `verified` or
`unverified`.

## Done criterion

Done when every workflow from *Context* has an execution table, every user
action has an evaluation row, and every (state × enabled control) pair has a
prevention row. The chat reply gives the report path and the count of
findings per severity.

## Self-check

1. Count the workflows in the source list and the execution tables in the
   report. Do the two counts match?
2. For each disabled-or-hidden condition you found by grep, is the control
   in the prevention table?
3. Is every finding marked `verified` (with a screenshot path that exists)
   or `unverified` (with a reason)?
4. Does any sentence in the conceptual model name a code identifier? It
   should not.
