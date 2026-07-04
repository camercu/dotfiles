---
name: harden
description: Iterative refinement loop for taking a change to a high quality bar. Sequences exercise→friction, grill→decide, TDD slices, then review→soundness→simplify→architecture→test-health→docs passes — repeating until a full round finds nothing significant — under fixed discipline (authority docs sacred, commit per slice, verify every slice, reverse your own calls on evidence, capture decisions durably). Use when the user wants to build or refine something "properly", harden a change, run a multi-pass quality loop, evaluate an API as a real consumer, or asks to "harden", "do this properly", "full quality pass", "refine loop", "keep going until clean", or "production-grade" work. Gated — stops for the user's call at authority conflicts, fix decisions, architecture do/decline, and irreversible actions.
---

# Harden

Gated multi-phase loop: change → high quality bar. Not replace specialist skills —
**sequence** them + enforce the connective discipline. Stack-agnostic: phases hold
anywhere; only commands + doc locations differ (detect Phase 0).

Bar = **maintenance-first**: every pass ask whether change leaves system easier to
understand/change/repair, not just whether it works. Repair before expand, prefer
simplicity, remove more than add, preserve knowledge, design for change.

## Non-negotiable invariants (active EVERY phase)

Spine. Override convenience always.

1. **Authority docs sacred.** Spec, ADR, design doc, agent instructions,
   documented contract = authoritative. Change that *reverses* one → **STOP,
   quote the exact conflict + implications + recommendation**. Never silently
   override, never silently edit doc to match new behavior. Approved contract
   change → update *every* reference; a half-updated self-contradicting doc =
   defect.
2. **Commit per vertical slice.** One logical change = one commit, right after
   green. Never bundle unrelated. Mark breaking changes. Follow project convention.
3. **Verify every slice.** Full verification matrix (Phase 0) after each slice,
   not just at end. Slice not done till green across every config it affects.
4. **Intellectual honesty beats momentum.** Trace claims vs actual code.
   "Considered and declined" = first-class: evidence kills a plan (yours or the
   user's) → say so + why. Reverse own rec when code contradicts. Never report
   green when it isn't.
5. **Capture decisions durably.** Load-bearing decisions — esp declines/reversals
   — go somewhere permanent (ADR, commit-body rationale, friction report), not
   just the conversation.
6. **Named passes delegated, not simulated.** A phase naming a skill = **invoke
   that skill via the Skill tool**; inline reasoning supplements, never replaces
   the call. Analysis by hand w/ invocation skipped = a skipped pass — record it
   (Closing ledger), don't self-substitute + report it as run. Invoking harden =
   consent to these sub-skill spawns; don't re-litigate spawn-aversion each pass.

## Right-size to blast radius (before Phase 0)

Machinery scales to the change; invariants never do. Judge blast radius first,
proportion ceremony to it — under-spending on a tiny change as wrong as
over-spending.

- **Consumer-surface** (public API, CLI, behavior): full weight — dogfood Phase 1,
  multi-angle review, the works.
- **No-consumer-surface** (internal test / refactor / doc / lockfile): friction
  source = **diff review**, not consumption; passes acting on consumer surface go
  **N/A** (Closing ledger), not skipped.
- **Pass weight tracks surface**: one focused review agent can replace a heavy
  fan-out on a small diff; a gate w/ one obvious option = one `AskUserQuestion`,
  not a full `grill-me`. Near-done diff where Simplify + Architecture both plausibly
  conclude "already right shape" → one structural-review agent carries both (still
  log both ledger rows w/ the shared finding). Down-weight = a judgment call you
  *record*, not a corner cut.

If the environment forbids spawning, degrade a delegated pass to the narrowest
agent preserving independence (one review agent, not eight finders) + mark it —
never silently self-substitute (#6).

## Phase 0 — Calibrate (silent, no gate)

Detect conventions before touching anything:
- **Verification matrix**: how project builds/tests/lints — task runner (`just`,
  `make`, `npm`, `cargo`, `go`, `gradle`…) or native toolchain. Commands gating a
  change across *every* config (targets, feature flags, OS). = invariant #3's list.
- **Authority doc**: spec, `docs/adr/`, design notes, `CONTEXT.md`, agent/contributor
  instructions, README contract section. None → treat README + public API + tests as
  the working contract, say so.
- **Commit/branch rules**: commit format, co-author rules, branch policy.
- **Pass skills present**: which Phase-4 pass skills the session offers
  (`code-review`, `simplify`, `improve-architecture`, `test-design-reviewer`). That
  set = the ledger checklist (#6) — one row each, RAN or SKIPPED-with-reason.

State detected matrix + authority doc in one line, proceed.

## The loop

Run phases in order, then **repeat the post-implementation passes till a full round
finds nothing significant** — convergence, not a single pass. Every fix = a slice
(phase 3) re-entering the passes, so each new change gets reviewed too; loop reaches
a fixpoint.

*Significant* = worth a slice: bug, coverage/contract gap, flaky/slow test,
reframing earning its keep, doc contradicting code. Cosmetic nits + false positives
= note-and-skip. **Declare done only after a round found nothing significant;
demonstrate convergence, don't predict it.** Then close back to phase 1: re-exercise
as consumer, confirm original friction gone.

**Convergence round = fresh subagent, not the implementing context.** Author context
is polluted — primed to see own work correct. Spawn a clean agent for the final pass.
Give it only: landed commit range, original friction list, verification matrix,
authority doc location — *not* the fix rationale or session probes (it derives its
own). Overlapping probes = the point (independent re-derivation); don't hand yours
over to "save work". It re-exercises as consumer (phase 1 discipline, adversarial
included), re-runs the matrix, reports findings — fed to the loop like any round.
Main context relays its verdict verbatim in Closing, marked independent.

Small-change collapse: if the Phase-4 Review agent reads the *final* post-fix range
unprimed, it already meets this contract — don't spawn a second identical one. They
stay separate only when Review ran mid-loop, before later slices landed.

Skip a phase only w/ a stated reason.

### 1 — Exercise → friction
Run the `dogfood` skill — it owns this pass (docs-first cold walk, full
public-surface coverage, adversarial misuse, sandboxed `/tmp` scratch, report-only).
Cold mode default; its fresh-subagent mode when this context already worked the
target. Output = ranked friction report = phase 2's input (`soundness` findings feed
the Soundness pass). Convergence close = `dogfood re-eval <report>`.

`dogfood` self-determines N/A on a change w/ no consumer-observable surface + fast-
exits — carry that to the ledger; friction source there = Phase-4 Review, pulled
forward.

### 2 — Grill → decide ⟨GATE⟩
Each finding → walk the decision tree, **recommend**, but the call is the user's. Use
`grill-me`. Challenge every option w/ codebase evidence; prefer what the code
supports over the elegant-sounding option. Resolve inter-decision dependencies first.
**Gate: don't implement till the user chose.** Check each chosen fix vs authority doc
(#1) before it enters the plan. No fixable findings → gate vacuous: note it + proceed
to Phase 4, don't manufacture a stop.

### 3 — TDD slices + verify
Slice approved work into vertical, independently-shippable pieces (`to-tasks` if
large). Each: `tdd` (red→green→refactor) → verify matrix (#3) → commit (#2). Sequence
independent slices freely; land the riskiest / widest-blast-radius slice last.

### 4 — Review → Soundness → Simplify → Architecture → Test-health → Docs
Post-implementation passes over the slices just landed. Each can reverse on evidence
(#4); each non-trivial fix re-enters phase 3 as its own slice + commit.

- **Review** — **invoke `code-review`** (#6). Its findings + your reasoning, two
  lenses:
  - *Inside the box* — bugs, regressions, **coverage gaps** (untested wiring = the
    classic miss), security, design as written. Each finding = **lead, not ticket**:
    defects cluster — name the class, sweep siblings; a docs/behavior mismatch often
    indicts a whole class of code.
  - *Outside the box (first principles)* — treat the current shape as accidental.
    Rebuilt from scratch, what would never get built? Hunt **code judo**: a
    behavior-preserving reframing deleting whole branches/helpers/concepts, not minor
    cleanups. Challenge each abstraction (earns its keep, or a wrapper?), each
    special-case conditional in an unrelated flow, each misplaced layer, each loose
    type a sharper model would forbid, any change bloating a file/function past what a
    reader holds. Question the project's *own* constraints — a documented decision can
    be the real defect.

  Apply clear in-contract wins directly. Don't suppress the rest: a reframing
  reversing an authority doc = conflict (#1) → gate w/ the behavior-equivalence
  argument + recommendation; one too big for a slice → `to-tasks` plan. Ambition
  unbounded; authority to land it is not.
- **Soundness** — run when the change touches an invariant the language won't check
  (unchecked memory/FFI/raw pointers, concurrency or shared mutable state, privilege
  boundaries, "call A before B" lifecycles, permission checks); else "no
  unchecked-invariant surface" + skip. Enumerate *every* op carrying a precondition
  the toolchain won't verify. Each gets one of two, no third:
  - **upheld internally** for every input + state, or
  - **pushed to the caller** via a fail-closed mechanism — a signature marking the
    obligation (e.g. Rust `unsafe fn`), a typed precondition, or a runtime guard
    rejecting bad input — **and** documented.

  Headline smell: a **normal-looking surface** (public fn, no warning in signature)
  hiding a precondition it can't enforce — guard it or make the signature announce
  the obligation. A wrapper implying a guarantee it doesn't uphold = defect (fix or
  delete, never keep for symmetry). Treat every safety *claim in docs/comments* ("raw
  access confined to X", "always single-threaded", "callers must…") as a checkable
  invariant — verify vs code, fix whichever lies. Adding a precondition marker or
  fail-closed guard to a **public** contract = breaking change → ⟨GATE⟩;
  internal-only = capture (#5).
- **Simplify** — **invoke `simplify`** (#6): reuse / quality / efficiency. Guard
  over-simplification; note-and-skip false positives.
- **Architecture** — **invoke `improve-architecture`** (#6): deepening via the
  deletion test. ⟨GATE⟩ on do-vs-decline. Decline = valid, common — capture *why*
  (#5).
- **Test-health** — **invoke `test-design-reviewer`** if present (#6): hunt
  slow/flaky tests. **Never tolerate; fix the source** — no sleeps-as-sync, no
  retry-on-flake (a race in a test usually = a real ordering bug). Replace shared
  mutable global state w/ per-test isolation; replace real I/O / clocks w/ injected
  or nullable infra (functional core / imperative shell). At most one narrow
  real-infra contract test per boundary. Trace tests to acceptance criteria, close
  *behavior* gaps not just uncovered lines. A quality bar that matters (coverage,
  lint, perf budget) → lock w/ an enforcement test or **ratchet**.
- **Docs** — propagate every behavior change into all docs describing it: README,
  API docs, man pages, CLI help, examples, changelog. Regenerate generated docs from
  source; a doc contradicting code = defect. (Reversing an authority doc → gate, #1.)

## Gate protocol

HARD-STOP, hand the decision to the user at:
- **Authority conflict** — a change would reverse a documented decision.
- **Fix selection** (phase 2) — which approach.
- **Architecture do-vs-decline** (phase 4).
- **Public safety-contract change** (phase 4 Soundness) — a precondition marker or
  fail-closed guard callers must now satisfy; a breaking interface change.
- **Any irreversible / outward-facing action** — push, publish, delete, migration,
  dependency change.

Between gates, run autonomously. Each gate: options, evidence, a clear
recommendation, wait. `AskUserQuestion` for discrete choices; prose for open
grilling.

## Closing

Summarize:
- slices landed (commit subjects), decisions captured (ADRs/footers);
- **Phase-4 pass ledger** — one row per pass skill Phase 0 detected, one of three
  states (N/A ≠ dodge — forcing N/A→RAN = waste, N/A→SKIPPED = false guilt):
  - **RAN** — skill invoked via Skill tool; give its result (findings acted on /
    declined). No invocation = SKIPPED, not RAN (#6). A skill that self-declines per
    its *own* guardrails (e.g. `improve-architecture` bailing on a few-caller,
    correct-altitude change) = RAN (declined) — record why.
  - **N/A** — no surface the pass acts on (say which — e.g. simplify on a doc-only
    diff).
  - **SKIPPED** — surface existed, chose not to run; give the reason.
- final verification-matrix status, and **that the last round was clean per the fresh
  subagent** (convergence, independent) — or name significant findings deliberately
  deferred + why.

Be plain about anything skipped or still red.
