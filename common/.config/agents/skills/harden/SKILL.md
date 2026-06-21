---
name: harden
description: Iterative refinement loop for taking a change to a high quality bar. Sequences exercise→friction, grill→decide, TDD slices, then review→simplify→architecture→test-health→docs passes — repeating until a full round finds nothing significant — under fixed discipline (authority docs sacred, commit per slice, verify every slice, reverse your own calls on evidence, capture decisions durably). Use when the user wants to build or refine something "properly", harden a change, run a multi-pass quality loop, evaluate an API as a real consumer, or asks to "harden", "do this properly", "full quality pass", "refine loop", "keep going until clean", or "production-grade" work. Gated — stops for the user's call at authority conflicts, fix decisions, architecture do/decline, and irreversible actions.
---

# Harden

A gated, multi-phase loop for taking a change from intent to a high quality bar.
It does not replace the specialist skills — it **sequences** them and enforces
the connective discipline that makes the result trustworthy. Language- and
stack-agnostic: the phases hold for any project; only the concrete commands and
doc locations differ (detect them in Phase 0).

The bar is **maintenance-first**: every pass asks whether the change leaves the
system easier to understand, change, and repair — not just whether it works.
Repair before expanding, prefer simplicity, remove more than you add, preserve
knowledge, design for change. (See the global maintenance-first values, if
present.)

## Non-negotiable invariants (active in EVERY phase)

These are the spine. They override convenience at all times.

1. **Authority docs are sacred.** A spec, ADR, design doc, agent instructions,
   or documented contract is authoritative. If an improvement would *reverse* a
   documented decision, **STOP and surface the exact conflict** (quote it) with
   implications and a recommendation. Never silently override it, and never
   silently edit the doc to match new behavior. When a contract change IS
   approved, update *every* reference to it — a half-updated doc that
   self-contradicts is a defect.
2. **Commit per vertical slice.** One logical change = one commit, made right
   after it goes green. Never bundle unrelated changes. Mark breaking changes
   explicitly. Follow the project's commit convention.
3. **Verify every slice.** Run the project's full verification matrix (see
   Calibrate) after each slice, not just at the end. A slice isn't done until
   it's green across every configuration it can affect.
4. **Intellectual honesty beats momentum.** Trace claims against the actual
   code. "Considered and declined" is a first-class outcome: if evidence kills a
   plan (yours or the user's), say so and why. Reverse your own recommendation
   when the code contradicts it. Never report green when it isn't.
5. **Capture decisions durably.** Load-bearing decisions — especially declines
   and reversals — go somewhere permanent: an ADR, a commit-body rationale, or
   the friction report. Not just the conversation.

## Phase 0 — Calibrate (silent, no gate)

Detect the project's conventions before touching anything:

- **Verification matrix**: find how the project builds, tests, and lints —
  a task runner (`just`, `make`, `npm`/`pnpm`, `cargo`, `go`, `gradle`, …) or
  the native toolchain. List the commands that gate a change across *every*
  configuration it ships (targets, feature flags, OS). This is invariant #3's
  checklist.
- **Authority doc**: look for a spec, `docs/adr/`, design notes, `CONTEXT.md`,
  agent/contributor instructions, or a README contract section. If none exists,
  treat the README + public API + tests as the working contract and say so.
- **Commit/branch rules**: read contributor/agent instructions for commit
  format, co-author rules, and branch policy.

State the detected matrix + authority doc in one line, then proceed.

## The loop

Run the phases in order, then **repeat the post-implementation passes until a
full round surfaces no significant findings** — convergence, not a single pass.
Every fix a pass produces is itself a slice (phase 3) that re-enters the passes,
so each new change is reviewed too; the loop reaches a fixpoint, it doesn't just
run once.

A *significant* finding is one worth a slice: a bug, a coverage or contract gap,
a flaky/slow test, a reframing that earns its keep, a doc that contradicts the
code. Cosmetic nits and false positives are note-and-skip — they are not loop
fuel. **Declare done only after running a round that found nothing significant;
demonstrate convergence, don't predict it.** Then close the loop back to phase 1:
re-exercise as a consumer to confirm the original friction is actually gone.

Skip a phase only with a stated reason.

### 1 — Exercise → friction
Use the thing as a real consumer would: build a small client against the API,
run the app (`run`/`verify` skills), or walk the change end-to-end. Collect
concrete friction notes (file:line, what surprised you, what fought you). Output
is a ranked friction list, not a vibe.

### 2 — Grill → decide  ⟨GATE⟩
For each finding, walk the decision tree and **recommend**, but the call is the
user's. Use the `grill-me` skill. Challenge every option with codebase evidence;
prefer the option the code supports over the elegant-sounding one. Resolve
dependencies between decisions first. **Gate: do not implement until the user
has chosen.** Check each chosen fix against the authority doc (invariant #1)
before it enters the plan.

### 3 — TDD slices + verify
Slice the approved work into vertical, independently-shippable pieces (`to-tasks`
if large). For each: `tdd` (red→green→refactor) → verify matrix (invariant #3) →
commit (invariant #2). Sequence independent slices freely; land the riskiest /
widest-blast-radius slice last when practical.

### 4 — Review → Simplify → Architecture → Test-health → Docs
Post-implementation passes over the slices just landed. Each can reverse on
evidence (invariant #4); each non-trivial fix re-enters phase 3 as its own slice
+ commit.

- **Review** (use a code-review skill/tool if present): two lenses.
  - *Inside the box* — bugs, regressions, **coverage gaps** (untested wiring is
    the classic miss), security, design of the change as written. Fix findings.
  - *Outside the box (first principles)* — treat the current shape as
    accidental, not inevitable. Rebuilding it from scratch, what would never get
    built? Hunt **code judo**: a behavior-preserving reframing that deletes
    whole branches, helpers, or concepts — not minor cleanups. Challenge each
    abstraction (does it earn its keep, or is it a wrapper?), each special-case
    conditional in an unrelated flow, each misplaced layer, each loose type a
    sharper model would forbid, and any change that bloats a file or function
    past what a reader can hold. Question the project's *own* constraints — a
    documented decision can be the real defect; don't grade the diff against a
    premise you distrust.

  Apply clear wins within the contract directly. Don't suppress the rest: a
  reframing that reverses an authority doc is an authority conflict (invariant
  #1) — take it to the gate with the behavior-equivalence argument and a
  recommendation; one too big for a slice becomes a `to-tasks` plan. Ambition
  unbounded; authority to land it is not.
- **Simplify** (`simplify`): reuse / quality / efficiency. Guard against
  over-simplification; note-and-skip false positives rather than forcing them.
- **Architecture** (`improve-architecture`): deepening opportunities via the
  deletion test. ⟨GATE⟩ on do-vs-decline. A decline is a valid, common outcome —
  capture *why* durably (invariant #5).
- **Test-health**: hunt slow/flaky tests. **Never tolerate them; fix the
  source**, don't mask it (no sleeps-as-sync, no retry-on-flake) — a race in a
  test usually means a real ordering bug in the code. Replace shared mutable
  global state with per-test isolation; replace real I/O / clocks with injected
  or nullable infrastructure (functional core / imperative shell). Keep at most
  one narrow real-infrastructure contract test per boundary. Trace tests back to
  the acceptance criteria and close *behavior* gaps, not just uncovered lines.
  Where a quality bar matters — coverage, a lint, a perf budget — lock it with an
  enforcement test or **ratchet** so it can never silently regress.
- **Docs**: propagate every behavior change from this round into all docs that
  describe it — README, reference/API docs, man pages, CLI help, examples,
  changelog. Regenerate generated docs from their source and keep the two in
  sync; a doc that contradicts the code is a defect. (Reversing an authority doc
  still goes to the gate — invariant #1.)

## Gate protocol

HARD-STOP and hand the decision to the user at:
- **Authority conflict** — a change would reverse a documented decision.
- **Fix selection** (phase 2) — which approach to take.
- **Architecture do-vs-decline** (phase 4).
- **Any irreversible / outward-facing action** — push, publish, delete,
  migration, dependency change.

Between gates, run autonomously. At each gate: state the options, the evidence,
and a clear recommendation, then wait. `AskUserQuestion` suits discrete choices;
prose suits open grilling.

## Closing

Summarize: slices landed (with commit subjects), decisions captured (ADRs /
footers), passes run and what each changed or declined, the final
verification-matrix status, and **that the last round was clean** (convergence
reached) — or name the significant findings deliberately deferred and why. Be
plain about anything skipped or still red.
