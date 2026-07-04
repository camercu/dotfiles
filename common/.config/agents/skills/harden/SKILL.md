---
name: harden
description: Iterative refinement loop for taking a change to a high quality bar. Sequences exercise→friction, grill→decide, TDD slices, then review→soundness→simplify→architecture→test-health→docs passes — repeating until a full round finds nothing significant — under fixed discipline (authority docs sacred, commit per slice, verify every slice, reverse your own calls on evidence, capture decisions durably). Use when the user wants to build or refine something "properly", harden a change, run a multi-pass quality loop, evaluate an API as a real consumer, or asks to "harden", "do this properly", "full quality pass", "refine loop", "keep going until clean", or "production-grade" work. Gated — stops for the user's call at authority conflicts, fix decisions, architecture do/decline, and irreversible actions.
---

# Harden

Gated multi-phase loop: take a change from intent to a high quality bar. Doesn't
replace specialist skills — **sequences** them + enforces the connective
discipline that makes the result trustworthy. Language/stack-agnostic: phases
hold anywhere; only commands + doc locations differ (detect in Phase 0).

Bar = **maintenance-first**: every pass asks whether the change leaves the system
easier to understand/change/repair, not just whether it works. Repair before
expand, prefer simplicity, remove more than add, preserve knowledge, design for
change. (See global maintenance-first values.)

## Non-negotiable invariants (active EVERY phase)

Spine. Override convenience always.

1. **Authority docs sacred.** Spec, ADR, design doc, agent instructions,
   documented contract = authoritative. An improvement that would *reverse* a
   documented decision → **STOP, surface the exact conflict** (quote it) +
   implications + recommendation. Never silently override, never silently edit
   the doc to match new behavior. Approved contract change → update *every*
   reference; a half-updated self-contradicting doc = defect.
2. **Commit per vertical slice.** One logical change = one commit, right after
   green. Never bundle unrelated. Mark breaking changes. Follow project commit
   convention.
3. **Verify every slice.** Run the full verification matrix (Phase 0) after each
   slice, not just at end. Slice not done until green across every config it
   affects.
4. **Intellectual honesty beats momentum.** Trace claims vs actual code.
   "Considered and declined" = first-class: evidence kills a plan (yours or the
   user's) → say so + why. Reverse your own rec when code contradicts. Never
   report green when it isn't.
5. **Capture decisions durably.** Load-bearing decisions — esp declines/reversals
   — go somewhere permanent: ADR, commit-body rationale, friction report. Not
   just the conversation.
6. **Named passes delegated, not simulated.** A phase naming a skill is performed
   by **invoking that skill via the Skill tool** — inline reasoning supplements
   the result, never replaces the call. Analysis by hand with the invocation
   skipped = a skipped pass; record it as such (Closing ledger), don't
   self-substitute and report the pass as run.

## Right-size to blast radius (before Phase 0)

Machinery scales to the change; the invariants never do. Judge blast radius
first, proportion the ceremony to it — a 10-line test/doc diff and a
1000-line subsystem run the *same* phases at *different* weights, and
under-spending on a tiny change is as wrong as over-spending.

- **Consumer-surface changes** (public API, CLI, behavior): full weight —
  dogfood Phase 1, multi-angle review, the works.
- **No-consumer-surface changes** (internal test / refactor / doc / lockfile):
  friction source = **diff review**, not consumption; passes that act on
  consumer surface go **N/A** (Closing ledger), not skipped.
- **Pass weight tracks surface, not a fixed script**: one focused review agent
  can stand in for a heavy fan-out on a small diff; a gate with one obvious
  option is one `AskUserQuestion`, not a full `grill-me` interview. Down-weight
  is a judgment call you *record* (Closing ledger), not a corner cut.

Delegation vs spawn-aversion: invoking harden = consent to the sub-skill spawns
its passes need. If the environment still forbids spawning, degrade a delegated
pass to the narrowest agent that preserves independence (one review agent, not
eight finders) and mark it in the ledger — never silently self-substitute (#6).

## Phase 0 — Calibrate (silent, no gate)

Detect conventions before touching anything:
- **Verification matrix**: how the project builds/tests/lints — task runner
  (`just`, `make`, `npm`/`pnpm`, `cargo`, `go`, `gradle`…) or native toolchain.
  List commands gating a change across *every* config (targets, feature flags,
  OS). = invariant #3's checklist.
- **Authority doc**: spec, `docs/adr/`, design notes, `CONTEXT.md`,
  agent/contributor instructions, README contract section. None → treat README +
  public API + tests as the working contract, say so.
- **Commit/branch rules**: commit format, co-author rules, branch policy.
- **Pass skills present**: note which Phase-4 pass skills the session offers
  (`code-review`, `simplify`, `improve-architecture`, `test-design-reviewer`).
  That set = the Phase-4 invocation checklist the Closing ledger (#6) must
  account for — one row per skill, invoked or SKIPPED-with-reason.

State detected matrix + authority doc in one line, proceed.

## The loop

Run phases in order, then **repeat the post-implementation passes until a full
round finds nothing significant** — convergence, not a single pass. Every fix =
a slice (phase 3) that re-enters the passes, so each new change is reviewed too;
the loop reaches a fixpoint.

*Significant* finding = worth a slice: bug, coverage/contract gap, flaky/slow
test, reframing that earns its keep, doc contradicting code. Cosmetic nits +
false positives = note-and-skip, not loop fuel. **Declare done only after a round
found nothing significant; demonstrate convergence, don't predict it.** Then
close the loop back to phase 1: re-exercise as a consumer, confirm the original
friction is gone.

**Convergence round = fresh subagent, not the implementing context.** Author
context is polluted: primed to see its work as correct, re-runs the probes it
already wrote. Spawn a clean agent for the final pass. Give it only the landed
commit range, the original friction list, the verification matrix, and the
authority doc location — *not* the fix rationale or the session's probes (it
derives its own). It re-exercises as a consumer (phase 1 discipline, adversarial
included), re-runs the matrix, reports findings — fed to the loop like any round
(significant → phase 2/3 in main context; clean → converged). Main context
relays its verdict verbatim in the Closing, marked independent. On a small
change this **collapses into the Phase-4 Review agent**: if that agent reads the
*final* post-fix range unprimed, it already meets the convergence contract —
don't spawn a second identical one. They stay separate only when Review ran
mid-loop, before later slices landed.

Skip a phase only with a stated reason.

### 1 — Exercise → friction
Run the `dogfood` skill — it owns this whole pass: docs-first cold walk, full
public-surface coverage, adversarial misuse, sandboxed scratch in `/tmp`,
report-only. Cold mode by default; its fresh-subagent mode when this context
already worked on the target. Output = its ranked friction report; those
findings = phase 2's input (`soundness` findings feed the Soundness pass).
Closing the loop at convergence = `dogfood re-eval <report>` for the
resolved / still-live delta.

`dogfood` self-determines N/A on a change with no consumer-observable surface
(internal test, refactor, doc, lockfile) and fast-exits — carry that verdict to
the ledger; friction source there = Phase-4 Review, pulled forward.

### 2 — Grill → decide ⟨GATE⟩
Each finding → walk the decision tree, **recommend**, but the call is the user's.
Use `grill-me`. Challenge every option w/ codebase evidence; prefer the option
the code supports over the elegant-sounding one. Resolve dependencies between
decisions first. **Gate: don't implement until the user chose.** Check each
chosen fix vs the authority doc (#1) before it enters the plan.

### 3 — TDD slices + verify
Slice approved work into vertical, independently-shippable pieces (`to-tasks` if
large). Each: `tdd` (red→green→refactor) → verify matrix (#3) → commit (#2).
Sequence independent slices freely; land the riskiest / widest-blast-radius slice
last when practical.

### 4 — Review → Soundness → Simplify → Architecture → Test-health → Docs
Post-implementation passes over the slices just landed. Each can reverse on
evidence (#4); each non-trivial fix re-enters phase 3 as its own slice + commit.

- **Review** — **invoke the `code-review` skill** (Skill tool; #6). Its findings
  plus your own reasoning, through two lenses:
  - *Inside the box* — bugs, regressions, **coverage gaps** (untested wiring =
    the classic miss), security, design as written. Fix findings. Each finding =
    **lead, not ticket**: defects cluster — name its class, sweep siblings
    (maintenance-first); a docs/behavior mismatch here often indicts a whole
    class of code.
  - *Outside the box (first principles)* — treat the current shape as accidental,
    not inevitable. Rebuilt from scratch, what would never get built? Hunt **code
    judo**: a behavior-preserving reframing that deletes whole
    branches/helpers/concepts — not minor cleanups. Challenge each abstraction
    (earns its keep, or a wrapper?), each special-case conditional in an
    unrelated flow, each misplaced layer, each loose type a sharper model would
    forbid, any change bloating a file/function past what a reader holds.
    Question the project's *own* constraints — a documented decision can be the
    real defect; don't grade the diff against a premise you distrust.

  Apply clear wins within the contract directly. Don't suppress the rest: a
  reframing reversing an authority doc = authority conflict (#1) → gate it w/ the
  behavior-equivalence argument + a recommendation; one too big for a slice →
  `to-tasks` plan. Ambition unbounded; authority to land it is not.
- **Soundness** (run when the change touches an invariant the type system
  doesn't enforce — `unsafe`/FFI/raw memory, concurrency or shared mutable
  state, privilege boundaries, "must call A before B" lifecycles, permission
  checks; else "no unsafe surface" + skip). Enumerate *every* op in the changed
  surface carrying a precondition the compiler won't check. Each gets one of two,
  no third: invariant **upheld internally** for every input+state, or
  **pushed to the caller** via the language's own fail-closed mechanism
  (`unsafe fn` / typed precondition / checked guard) **and** documented.
  Hunt hardest for the headline smell: a **safe-typed surface** (safe fn, public
  method) hiding a precondition it can't enforce — latent bug, not convenience;
  guard it or give it an unsafe signature. A wrapper implying a guarantee it
  doesn't uphold = defect (correct or delete, never keep for symmetry). Treat
  every safety *claim in docs/comments* ("all unsafe confined to X", "always
  single-threaded", "callers must…") as a checkable invariant — verify vs code,
  fix whichever lies. Changing a **public** fn's safety signature (adding
  `unsafe`/a panic guard) = breaking change → ⟨GATE⟩; internal-only = capture (#5).
- **Simplify** — **invoke the `simplify` skill** (Skill tool; #6): reuse /
  quality / efficiency. Guard over-simplification; note-and-skip false
  positives, don't force them.
- **Architecture** — **invoke the `improve-architecture` skill** (Skill tool;
  #6): deepening via the deletion test. ⟨GATE⟩ on do-vs-decline. Decline =
  valid, common — capture *why* durably (#5).
- **Test-health** (**invoke `test-design-reviewer`** if present; #6): hunt
  slow/flaky tests. **Never tolerate; fix the source**,
  don't mask (no sleeps-as-sync, no retry-on-flake) — a race in a test usually =
  a real ordering bug in the code. Replace shared mutable global state w/
  per-test isolation; replace real I/O / clocks w/ injected or nullable infra
  (functional core / imperative shell). Keep at most one narrow real-infra
  contract test per boundary. Trace tests back to acceptance criteria, close
  *behavior* gaps not just uncovered lines. A quality bar that matters (coverage,
  lint, perf budget) → lock w/ an enforcement test or **ratchet** so it can't
  silently regress.
- **Docs**: propagate every behavior change this round into all docs describing
  it — README, reference/API docs, man pages, CLI help, examples, changelog.
  Regenerate generated docs from source, keep in sync; a doc contradicting code =
  defect. (Reversing an authority doc still → gate, #1.)

## Gate protocol

HARD-STOP, hand the decision to the user at:
- **Authority conflict** — a change would reverse a documented decision.
- **Fix selection** (phase 2) — which approach.
- **Architecture do-vs-decline** (phase 4).
- **Public safety-contract change** (phase 4 Soundness) — making a public fn
  `unsafe`, or adding a panic/guard; a breaking interface change.
- **Any irreversible / outward-facing action** — push, publish, delete,
  migration, dependency change.

Between gates, run autonomously. Each gate: state options, evidence, a clear
recommendation, wait. `AskUserQuestion` for discrete choices; prose for open
grilling.

## Closing

Summarize:
- slices landed (commit subjects), decisions captured (ADRs/footers);
- **Phase-4 pass ledger** — one row per pass skill Phase 0 detected, in one of
  three states (keep distinct; N/A ≠ dodge — forcing N/A→RAN = waste,
  N/A→SKIPPED = false guilt):
  - **RAN** — skill invoked via Skill tool; give its result (findings acted on /
    declined). No invocation = not RAN, it is SKIPPED (#6); inline analysis
    doesn't count.
  - **N/A** — no surface the pass acts on (say which — e.g. simplify/architecture
    on a doc-only diff).
  - **SKIPPED** — surface existed, chose not to run; give the reason.
- final verification-matrix status, and **that the last round was clean per the
  fresh subagent** (convergence, independent) — or name the significant findings
  deliberately deferred + why.

Be plain about anything skipped or still red.
