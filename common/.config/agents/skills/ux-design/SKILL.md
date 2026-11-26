---
name: ux-design
description: Use when planning or building a GUI or TUI screen, pane, control, or workflow, or when asked to "design the UI", "wireframe", "make it look/feel better", or theme an app. Not for static visual design without interaction; for usability reviews, use ux-audit. For command-line interfaces, use cli-design.
---

# UX design

## Overview

Design around user goals, then build and verify the interaction. Keep design decisions grounded in evidence and interaction rules independently testable. `tdd` drives implementation; `ux-audit` evaluates the running interface. 
The design rules describe general interaction principles. `cli-design`
specializes these principles for command-line interfaces, including
shell composition and programmatic consumption.


## Context

- Before planning, read the project's requirements, design docs, existing workflow tests, UI components, and affected screens. Use approved requirements as design authority and running behavior as evidence of the current experience. Resolve conflicts with the user.
- When choosing interaction patterns, inspect relevant domain applications and platform conventions. Reuse established patterns unless a documented user need warrants a deviation.
- When choosing or changing colors, read [palettes.md](palettes.md). Prefer the project's design system and user appearance preferences; use the palette defaults for new themes.
- When designing or verifying accessibility, consult [WCAG 2.2](https://www.w3.org/TR/WCAG22/) Level AA and, for non-web GUIs and TUIs, [WCAG2ICT](https://www.w3.org/TR/wcag2ict/) for applicable criteria. Account for terminal and assistive technology limitations.

## Plan

Record the following headings in the change's spec or task file. Scale detail to novelty, risk, and scope. Reuse approved decisions by reference; mark inapplicable items with a reason.

1. **Users and context.** Identify users, expertise, task frequency, operating conditions, accessibility needs, and success criteria. Cite existing evidence or user input; label assumptions and identify which need validation.
2. **Workflows.** List every affected user goal as a verb phrase with its steps, alternatives, and observable completion criteria. Cover normal, exceptional, and recovery paths. Write acceptance criteria for each workflow in user terms.
3. **Conceptual model.** Describe user-facing objects, relationships, actions, and lifecycle in domain vocabulary. Compare the model with evidence of users' mental models. Update the design docs if the model changes.
4. **Interaction and layout.** Wireframe the changed views and navigation, including the minimum supported size, scaling, resize, and overflow behavior. Use ASCII, a sketch, or an interactive prototype as needed to resolve uncertainty. Apply the design rules below; record consequential decisions and their rationale.
5. **States and feedback.** For every affected control and pane, specify applicable states, transitions, available actions, and visible results. Include empty, waiting, ready, busy, failed, disabled, stale, disconnected, partial, canceled, and uncertain outcomes where applicable. Distinguish operation completion from achievement of the user's goal.
6. **Constraints and recovery.** Identify likely slips, memory lapses, mode errors, and mistakes. Specify validation, safe defaults, safeguards, cancellation, undo, and interruption recovery for affected workflows.
7. **Accessibility and efficiency.** Specify input methods, focus order and restoration, reading order, assistive technology behavior, shortcuts and their discovery, and accelerators for frequent tasks. Identify applicable accessibility criteria and how to verify them.
8. **Design validation.** Walk through each workflow using Norman's action cycle: goal, plan, specify, perform, perceive, interpret, compare. At each step identify what the user must know, what evidence the interface supplies, and any gap. Resolve gaps in the design. For novel, risky, or uncertain interactions, evaluate a prototype with representative users where available; record findings and remaining assumptions.

**Gate.** Present the proposed workflows, wireframes, states, safeguards, and unresolved assumptions for materially new or changed interactions. Build after the user approves those decisions. Minor changes within an approved interaction pattern may reuse that approval. Return to the gate when a new design decision changes the approved workflow, conceptual model, or safeguards.

## Design rules

Apply every rule to each affected workflow; record exceptions with their rationale. Use the same rules for GUIs and TUIs.

- **Discoverability.** Make possible actions, their targets, prerequisites, and consequences apparent at the point of use. Give common and consequential actions prominent entry points; disclose infrequent or advanced options progressively.
- **Affordances and signifiers.** Provide actions users can actually perform and cues that accurately communicate them. Distinguish controls from content and distinguish available, focused, active, selected, and disabled states. Make gestures, shortcuts, and hidden interactions discoverable through accessible labels, hints, or help.
- **Mapping.** Align controls with their targets and effects through spatial, directional, temporal, and conventional mappings. Keep related controls near their objects; make action scope explicit.
- **Conceptual model and consistency.** Make the system image communicate one coherent model through terminology, navigation, controls, behavior, and help. Reuse domain and platform conventions. Make consequential modes and active targets explicit; eliminate unnecessary modes.
- **Feedback.** Acknowledge input promptly. Aim for immediate feedback within 100 ms; show pending feedback when delay becomes perceptible and progress for waits around 1 s or longer. For waits around 10 s or longer, support background work or completion notification where appropriate. Prevent unintended duplicate execution. Distinguish acknowledgment, completion, and verified outcome; expose relevant freshness, uncertainty, and partial results. Announce subtle changes and preserve useful content during refreshes.
- **Constraints and forgiveness.** Use physical, semantic, cultural, and logical constraints to guide valid actions. Enforce genuine invariants; accommodate legitimate variations in input and normalize when appropriate. Prefer safe defaults, prevention, previews, undo, and reversible actions. Require explicit confirmation or an interlock for consequential irreversible actions. Explain errors in user terms: what happened, why if known, what remains intact, and what to do next. Investigate the design causes of human errors.
- **User control.** Support escape, predictable navigation, cancellation, pause, resume, and reversal where meaningful and safe. Preserve work, selection, filters, and scroll position across interruptions and navigation. Keep automation observable and controllable; report its actual capabilities and side effects. Respect user preferences, privacy, and consent; make consequential choices explicit and reversible where feasible.
- **Recognition over recall.** Present the information required for each decision alongside its controls. Surface options, units, prior choices, examples, and relevant context. Use concise action labels and task-oriented help where the interaction alone cannot communicate enough.
- **Learnability and efficiency.** Provide discoverable paths for newcomers and efficient paths for experts. Reduce repeated entry and unnecessary steps; provide shortcuts, direct manipulation, search, presets, batch operations, or CLI parity where the workflow warrants them.
- **Visual and information design.** Establish hierarchy through alignment, proximity, spacing, typography, contrast, and meaningful ordering. Give information and actions prominence proportional to task relevance and frequency. Remove irrelevant decoration; match density to the task. Label data with units, scale, precision, and uncertainty where consequential. Evaluate first impressions (visceral), task performance (behavioral), and confidence in outcomes (reflective).
- **Inclusive interaction.** Meet applicable accessibility criteria. Provide semantic names, roles, values, states, logical reading and focus order, visible unobscured focus, keyboard escape, scalable presentation, sufficient contrast and target size, accessible status announcements, and alternative input paths. Convey essential information through more than color, position, sound, or motion alone. For TUIs, verify the actual terminal and assistive technology behavior; document platform limitations.

## Build

- **Test first.** Invoke `tdd` for each behavioral slice using the planned acceptance criteria. Keep interaction rules, validation, and state transitions independent of UI toolkit types; keep rendering and event translation at the boundary.
- **Explicit state.** Represent user-observable states and valid combinations explicitly. Render each applicable state and preserve useful data during transient failures where safe.
- **Single availability source.** Derive action execution, enabled state, and accessible disabled explanations from the same rules. Recheck prerequisites at execution when state can change.
- **One theme.** Use shared design tokens and component styles for recurring visual decisions. Keep data colormaps separate from UI colors. Enforce the design system through structure first, behavioral checks second, and review or a justified static guard per `~/.config/agents/guard-ladders.md` (Test guards). Demonstrate that any added guard detects a deliberate violation.
- **One layout model.** Use authoritative, composable layout constraints. Test spatial relationships, cross-view consistency, minimum size, and overflow rather than binding tests to a particular layout algorithm.

## Verify

1. Run the acceptance tests for every affected workflow and the design-system and layout checks.
2. Drive the running app through every affected workflow, including failure and recovery. Exercise supported input methods, keyboard-only navigation, focus, resizing, accessibility, and the planned state transitions. Capture evidence with the project's GUI or terminal driver. Test applicable accessibility criteria with automated checks and manual interaction; include assistive technology where supported.
3. For rendering-sensitive refactors, capture equivalent before and after frames using the same inputs, viewport, theme, and data. Rebuild and verify that each run uses the intended revision. Explain every meaningful visual difference.
4. Invoke `ux-audit` for every affected workflow. Use a fresh reviewer for substantial interaction changes. Reuse live evidence from step 2 where it covers the audit. Resolve findings, rerun affected checks, and re-audit.
5. For materially new, risky, or uncertain workflows, observe representative users attempting realistic tasks without revealing the solution. Record completion, errors, assistance, and time where relevant against the planned success criteria. Revise the design from the evidence. If users are unavailable, record human validation as outstanding; use the cognitive walkthrough and audit as interim evidence.

## Done criterion

Done when:

1. Every affected workflow is listed in the plan; all eight headings are complete or explicitly inapplicable, and required approvals are recorded.
2. Every affected workflow has passing acceptance tests; applicable design-system and layout checks pass, including the deliberate violation check when a guard is added or changed.
3. Every verification item has observed evidence or an explicit unverified status and reason. Unverified release-critical checks require user acceptance before reporting done.
4. `ux-audit` covers every affected workflow and has zero unresolved blocker or high findings unless the user explicitly accepts them. The same rule applies to findings from accessibility and human validation.
5. The report names the plan, test results, audit report, and validation evidence; lists failures, skipped checks, and outstanding assumptions; distinguishes functional verification from demonstrated usability.

## Self-check

1. Match the changed screens, controls, and workflows against the plan and test results. Every affected item is accounted for.
2. Trace each affected workflow through the action cycle and the design rules. Every gap is resolved or recorded with a rationale and status.
3. Exercise every changed action's availability, state transitions, safeguards, and recovery. The displayed state, disabled explanation, and actual execution agree.
4. Run the design-system and layout checks; inspect the applicable live and accessibility evidence. Every claimed pass has an observed result.
5. Compare the audit and validation findings with the final implementation. Every blocker or high finding is resolved with evidence or explicitly accepted by the user.
6. Check that every required approval and skill invocation occurred. Report every failed, skipped, or unverified check with its reason.
