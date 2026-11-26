---
name: ux-design
description: Use when planning or building a GUI or TUI screen, pane, control, or workflow, or when asked to "design the UI", "plan the screen", "wireframe", "make it look/feel better", or to theme an app. Pairs with tdd for the code; ends with ux-audit. Not for pure web visual design with no interaction.
---

# UX design

## Overview

The plan-then-build loop for a GUI or TUI change. The plan states the
workflows, the user's model, a wireframe and every state before any code.
The build keeps the UI layer thin over a tested pure core, so the rules
below fail in a test or a lint instead of living in review comments. This
skill sets the shape. `tdd` drives each slice, and `ux-audit` judges the
result.

## Plan

Write the plan into the change's spec or task file. Each item below is a
heading there.

1. **Workflows.** List the user goals the change serves, as verb phrases,
   each with its steps. Each workflow gets an acceptance test (the ATDD or
   e2e suite) before its UI exists. Design from these, not from the data
   types.
2. **Reference apps.** Name two or three apps the users already know for this
   job, and say what each one lends: a layout, a gesture, a readout. For SDR
   work: SDR#, SDR++, inspectrum, Universal Radio Hacker, and Sceptre (user
   favorites).
3. **Conceptual model.** Three sentences in the user's words, with no code
   identifiers. A change that alters the model updates the project's copy of
   it (spec or design doc).
4. **Wireframe.** An ASCII drawing of the screen after the change, with each
   control placed beside what it acts on.
5. **States.** For each touched pane and control: empty, waiting, failed,
   ready, busy (in flight), and disabled, with what it shows in each. Name
   the one primary action per view, and put rarer actions behind progressive
   disclosure (a menu, a collapsing section).

Gate: show the user the wireframe and the state list. Build only after
they agree.

## Build rules

- **Pure core, thin shell.** The decisions live in modules that name no UI
  toolkit type: view model, session, interaction state machine. Tests drive
  them directly. The UI layer turns toolkit input into one frame of a plain
  input struct, hands it to the core, and draws what the core returns.
- **States are enums.** A pane's content is `enum { Waiting, Failed, Ready(T) }`,
  never an `Option` that hides the failure. Each variant without data draws
  a note.
- **Availability has one source.** Each action is a function returning
  `Result<Command, Blocked>`. The control is enabled iff `Ok`, and while
  disabled its tooltip or hint is `Blocked::reason()`. Status-bar hints reuse
  the same string.
- **In-flight feedback.** An action that starts a job shows a pending state
  ("Writing …") from the moment it is sent, and blocks a duplicate until the
  job ends, fails or is canceled.
- **One theme.** Every color, font and size comes from one theme module. A
  lint bans the toolkit's color and font constructors outside it (clippy
  `disallowed-methods` in the crate's `clippy.toml`, with an expect attribute
  inside the theme), and a gate test plants a violation to prove the ban
  fires. Default palette: One Dark Pro, else Catppuccin Mocha. Their tokens
  are in [`palettes.md`](palettes.md); read it when picking or changing
  colors. Data colormaps (a spectrogram's viridis) stay apart from the
  theme.
- **One geometry.** One layout function returns every pane's rectangle, and
  drawing code draws into those rectangles. Layout tests pin the relations
  between panes.
- **TUI.** The same rules apply. Theme tokens are `Style` constants, the
  snapshot is a test backend's buffer, and the live drive is tmux.

## Verify

- Behavior change: `tdd` over the core, then drive the live app. Use the
  computer-use `app_*` tools for a GUI and `tmux send-keys`/`capture-pane`
  for a TUI. No display → report the live check as unverified.
- Refactor or theme-token move: diff a frame snapshot taken before against
  one taken after. Rebuild between the two, and confirm the binary changed
  (checksum). Report every differing region and why it differs, for example
  a frame-time readout.
- End of the change: run `ux-audit` on every workflow the change touched.

## Done criterion

Done when the plan has all five headings and the user approved the gate,
every workflow has an acceptance test that passes, the theme ban's gate
test passes, and the `ux-audit` report for the touched workflows has no
blocker or high finding left open without the user's decline.

## Self-check

1. Does `grep` for the toolkit's color and font constructors outside the
   theme module return zero hits?
2. Does every new action function return `Result<_, Blocked>` (or the
   project's equivalent), with the control's enabled state read from it?
3. Is any pane state still an `Option` that stands for both "not yet" and
   "failed"? There should be none.
4. Does every refactor commit body name the snapshot diff result?
