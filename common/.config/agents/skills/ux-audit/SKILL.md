---
name: ux-audit
description: Use when reviewing how usable a GUI or TUI workflow is, asked for a "Norman audit", "UX review", "usability check", "gulf of execution/evaluation", "error prevention check", or a "conceptual model" of an app. Runs from dogfood on every GUI/TUI target and from ux-design at the end of a GUI/TUI change. Not for static web visual polish or accessibility conformance alone.
---

# UX audit

## Overview

A Norman and usability audit of every workflow a GUI or TUI offers. It evaluates the conceptual model, the Gulf of Execution, the Gulf of Evaluation, and error prevention and recovery. Each claim rests on two sources: the code that decides what a control shows, and the running app. The output is a ranked findings file. This skill reports problems and proposes fixes, while implementation goes to `ux-design` or `tdd`.

## Context

- **Workflows.** Source workflows in this order: acceptance tests, then the spec's workflow or scope list, then the README. State each workflow as a verb phrase describing a user goal, such as "filter records and export a selection". A documented goal with no acceptance test is a finding.
- **Controls and their conditions.** Search the UI layer for every interactive widget and read the predicate that enables, disables, or hides it.
- **Live app.** Launch the app through the `run` skill. Drive a GUI with the computer-use `app_*` tools, and drive a TUI with `tmux send-keys` and `tmux capture-pane -p`. Use the project's snapshot hook when one exists.
- **Authority.** Live behavior overrides code reading, and code reading overrides docs.

## Steps

Open `.scratch/ux-audit/<run>/report.md` before step 1 and fill it as you go, per `~/.config/agents/record-as-you-go.md`.

1. **Conceptual model.** Write three sentences from the user's perspective using only what the user sees and does, with zero code identifiers. List every place where the screen suggests a conflicting model, such as a control that looks like it does X but does Y.
2. **Gulf of Execution.** Create one table per workflow with columns: step, signifier the user follows, and problem. Flag any of these problems: a missing signifier, an undocumented shortcut or modifier key, a control hidden until an earlier step, a control placed far from what it acts on, unnatural mapping on continuous controls such as sliders or zoom, inconsistent control placement across views, weak typographic hierarchy between primary readouts and secondary metadata, two controls that look alike, or a workflow that fails keyboard-only completion or lacks a visible focus indicator.
3. **Gulf of Evaluation.** Create one table with a row per user action: action, on-screen proof of state change, and gap. Check that the current mode and active selection stay persistently visible. Check latency feedback: instant updates under 100ms, a pending state between 100ms and 1s, and a progress indicator with a cancel action over 1s. Check for subtle completions that lack confirmation, silent no-ops, unlabeled pane meaning changes, WCAG AA contrast failures (4.5:1 for normal text, 3:1 for large text and UI components), and states encoded by color alone that fail grayscale legibility.
4. **Error prevention and recovery.** Enumerate the app's states: empty, waiting, ready, busy, and failed. For every enabled control in every state, record what clicking or pressing it does. Assign a constraint to every no-op or error row: disable it with a tooltip or status hint, hide it, or gate it with confirmation. Mark intentionally enabled, harmless controls as "keep" with the reason. Check that inputs enforce upfront constraints such as bounded ranges or pickers, that defaults and initial focus targets are safe, that destructive actions provide undo or explicit confirmation, and that every error state explains what failed, why, and how to recover.
5. **Verify live.** Reproduce every finding from steps 2 through 4 in the running app and attach the screenshot or captured pane path. Run a keyboard-only pass across every workflow and resize the window or terminal to its planned minimum dimensions to check for clipping, overlap, or unreadable truncation. Mark any finding you could not reproduce live as `unverified` with the reason, such as a missing display or an unsimulatable gesture.

## Report

Include these sections in order: context (app, commit, date, how it was driven), conceptual model, execution tables, evaluation table, error-prevention table, and findings. Give each finding a severity (`blocker`, `high`, `medium`, or `low`), a lens (`model`, `execution`, `evaluation`, or `prevention`), evidence (`file:line` and screenshot path), a proposed fix, and a status (`verified` or `unverified`).

## Done criterion

Done when all of the following hold:

1. Every workflow from *Context* has an execution table.
2. Every user action has an evaluation row.
3. Every pair of app state and enabled control has a prevention row.
4. Every workflow was tested keyboard-only and at minimum window or terminal size, or reported `unverified` with the reason.
5. The chat reply gives the report path and the count of findings per severity.

## Self-check

Run before reporting done:

1. Do the workflow count in the source list and the execution table count in the report match?
2. Does every enabled, disabled, or hidden control predicate found in code appear in the prevention table?
3. Does every finding have a status of `verified` with an existing screenshot path, or `unverified` with a reason?
4. Is every sentence in the conceptual model free of code identifiers?
5. Was every workflow tested using only the keyboard, with focus visibility checked at each step?
6. Was the app tested at its planned minimum window or terminal size for clipping and overflow?
7. Was every error state checked for a recovery action, and every destructive action checked for undo or confirmation?
