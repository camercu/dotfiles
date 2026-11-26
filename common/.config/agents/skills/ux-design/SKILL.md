---
name: ux-design
description: Use when planning or building a GUI or TUI screen, pane, control, or workflow, or when asked to "design the UI", "plan the screen", "wireframe", "make it look/feel better", or theme an app. Not for static web visual design with no interaction.
---

# UX design

## Overview

The plan-then-build loop for a GUI or TUI change. The plan specifies workflows, conceptual model, wireframe, states, safeguards, and keyboard navigation before code. The build keeps the UI layer thin over a tested pure core so rules fail in tests or lints. This skill sets the design shape; `tdd` drives each code slice, and `ux-audit` evaluates the finished workflows.

## Plan

Write the plan into the change's spec or task file. Each item below is a heading there.

1. **Workflows.** List each user goal as a verb phrase with its steps. Write one acceptance test per workflow before building its UI. Drive the design from these workflows rather than underlying data types.
2. **Reference apps.** Name two or three established apps in the target domain and state what each lends (a layout, gesture, or readout). Check project design docs for domain-specific favorites.
3. **Conceptual model.** Write three sentences in the user's vocabulary, free of code identifiers. Update the project's spec or design doc whenever a change alters this model.
4. **Wireframe.** Draw an ASCII layout of the changed screen. Place each control beside what it acts on, align continuous controls (sliders, axes, zoom, scroll) with natural mapping, keep control placement consistent across views, group related controls by proximity, distinguish primary readouts from secondary metadata through typographic hierarchy, and state the minimum window or terminal size plus resize and overflow behavior.
5. **States.** For every touched pane and control, specify what it shows in each state: empty, waiting, failed, ready, busy (in flight), and disabled. State how the screen persistently displays the current mode and active selection. Name the single primary action per view, and place secondary actions behind progressive disclosure (a menu or collapsing section).
6. **Constraints, defaults, and recovery.** Specify upfront input constraints (bounded ranges, pickers, format masks) and safe, non-destructive defaults. For every destructive or irreversible action, specify its safeguard (undo buffer, soft delete, or explicit confirmation). For every error state, specify the message stating what failed, why, and the recovery action.
7. **Keyboard and accelerators.** Specify the focus order, safe initial focus target, primary keyboard shortcuts, how users discover them (inline hints, status bar, or command palette), and any batch actions or CLI parity for repeat workflows.

**Gate:** Show the user the wireframe, state list, and safeguards. Proceed to build ONLY after the user approves them.

## Build rules

- **Pure core, thin shell.** Keep view models, session state, and interaction state machines in modules free of UI toolkit types so tests drive them directly. The UI shell converts toolkit events into a plain input frame, passes it to the core, and renders the core's output.
- **Explicit state types.** Represent every pane's content as a tagged union or discriminated state (`Waiting`, `Failed`, `Ready(T)`) so loading and failure stay distinct. Render an explicit message for every non-ready variant.
- **Single availability source.** Implement each action as a predicate returning either an executable command or a structured disabled reason. Drive the control's enabled state from that result, and display the disabled reason in tooltips and status-bar hints.
- **Latency-matched feedback.** Under 100ms, update immediately. Between 100ms and 1s, show an in-flight pending state ("Writing...") and block duplicate triggers until completion, failure, or cancellation. Over 1s, show progress (determinate when possible) with a cancel action. Confirm completion when the result is visually subtle.
- **Constraints, safe defaults, and forgiveness.** Constrain inputs upfront with bounded ranges, pickers, or format masks so invalid states are unrepresentable. Pre-populate safe, non-destructive defaults and focus targets. Every error state tells the user what happened, why, and how to recover (retry, revert, or dismiss). Prefer undoable actions over modal confirmations; gate only irreversible operations.
- **Clear signifiers, hierarchy, and accessibility.** Visually distinguish interactive controls from static content across default, hover, focus, active, and disabled states. Keep the current mode and active selection visibly surfaced at all times. Use typographic scale and weight to separate primary readouts from secondary metadata and control information density. Meet WCAG AA contrast (4.5:1 for normal text, 3:1 for large text and UI components). Pair every color-coded state with text, an icon, or a pattern so grayscale rendering stays legible. Ensure every interactive control is keyboard-operable with a visible focus indicator.
- **One theme.** Source every color, font, and size from a single theme module. Enforce a static lint or CI check that bans raw toolkit color and font constructors outside the theme module, backed by a gate test that plants a violation to prove the check fires. When picking or changing colors, read [`palettes.md`](palettes.md) (default: One Dark Pro, else Catppuccin Mocha). Keep data colormaps separate from the UI theme.
- **One geometry.** Compute every pane's rectangle in a single layout function and draw into those rectangles. Pin inter-pane relations, consistent cross-view placement, and minimum-size behavior with layout tests.
- **TUI parity.** Apply the same rules to terminal UIs using theme style constants, test-backend buffer snapshots, and automated terminal-driver verification.

## Verify

- **Behavior change:** Run `tdd` over the core, then drive the live app with an automated GUI or terminal driver. If no display or terminal host is available, report the live check as skipped with the reason.
- **Refactor or theme-token move:** Capture a frame snapshot before and after, rebuilding between runs and confirming the binary checksum changed. Report every differing region and its cause.
- **End of change:** Run `ux-audit` on every workflow the change touched.

## Done criterion

Done when all of the following hold:

1. The plan contains all seven headings and the user approved the gate.
2. Every workflow in the plan has a passing acceptance test.
3. The theme-ban gate test passes.
4. The `ux-audit` report for all touched workflows has zero open blocker or high findings (unless explicitly declined by the user).

## Self-check

Run before reporting done:

1. Does a static search or linter check for raw toolkit color and font constructors outside the theme module return zero hits?
2. Does every new action drive both its enabled state and its disabled hint from a single availability predicate?
3. Does every touched pane represent loading and failure as distinct states rather than a shared nullable or empty value?
4. Are inputs constrained upfront (ranges, pickers, masks) with safe, non-destructive defaults and focus targets?
5. Are current mode and active selection visibly surfaced on screen at all times?
6. Can every touched workflow be completed using only the keyboard, with a visible focus indicator at every step?
7. Does every error state include a recovery action, and does every destructive action have undo or confirmation?
8. When rendered in grayscale, are all states, alerts, and interactive controls still distinguishable?
9. Does every refactor commit body record the before and after snapshot diff result?
