---
name: harden
description: Use when user wants to build or refine something "properly", harden a change, run a multi-pass quality loop, evaluate an API as a real consumer, or says "do this properly", "full quality pass", "refine loop", "keep going until clean", "production-grade".
---

# Harden

## Overview

Take a change to a maintenance-first quality bar: exercise it as a consumer,
triage evidence, land fixes test-first, then review and verify within the
recorded review budget. Harden sequences
specialist skills (`dogfood`, `grill-me`, `tdd`, `simplify`,
`improve-architecture`, `test-design-reviewer`); each owns its method. Harden
owns order, gates, run state, and the convergence proof.

Run state lives in a **ledger** on disk, so `/clear` and resume are safe.

## Rules (every phase)

Commits, independent review, and skill invocation follow AGENTS.md
*Development process* and *Git*. Findings follow
`~/.config/agents/record-as-you-go.md`. Harden adds:

1. **Authority docs win.** Spec, ADR, design doc, `CONTEXT.md`, agent
   instructions, documented contract. A change that reverses one → gate: quote
   the conflict, implications, recommendation. Approved contract change →
   update every reference to it in the same slice; a half-updated doc
   contradicts itself.
2. **Slice green across the whole matrix.** Run the verification matrix after
   every slice on the affected configurations, and the final matrix on HEAD.
   Use AGENTS.md *Authoritative verification* for logs, exit codes and skips.
3. **Declines are results.** Evidence kills a plan (yours or the user's) → say
   so, with why. New evidence against a decline the user already chose → gate
   again, quoting the evidence. Record load-bearing decisions, declines
   included, in a durable home: ADR, or body of the nearest slice commit. No
   slice this run → ADR when load-bearing, else the closing report. Ledger
   only points at them.
4. **Evaluative passes follow the risk tier.** Evaluative =
   judges the work: Exercise, Review, Simplify, Architecture, Test-health,
   convergence. Propagating = applies a known change: TDD slices, fixes,
   Soundness, Docs; these need to know what changed. When run in context, record self-review in its row.
5. **Reuse evidence.** TDD supplies acceptance, boundary, and mutation
   evidence. Harden coordinates review. Carry forward pass evidence where
   fixes leave its scope intact. Repeat changed areas and uncovered behavior.

## Right-size

Use the risk tier in AGENTS.md. Record the highest-risk behavior, tier, and
review budget in the ledger. Defaults: low one focused review, medium one
round plus one targeted follow-up, high one initial round plus up to two
targeted follow-ups. High risk requires an independent review of the final
high-risk behavior. Budget limits repeated review, not required checks.

- **Consumer surface** (public API, CLI, observable behaviour): full loop.
- **No consumer surface** (internal refactor, test, doc, lockfile): friction
  comes from diff review, not consumption. Passes that act on consumer surface
  → `N/A` in the ledger.
- **Infrastructure code**: Exercise = converge on the target (check mode while
  the host is unreachable) plus the verify playbook.
- **Agent count.** Combine Review, Simplify, and Architecture where the
  same reviewer can cover them. Low risk can use one focused in-context
  review. Use a fresh reviewer where the risk tier warrants it. Split by
  subsystem only when the scope exceeds what one reviewer can cover.
- A gate with one obvious option = one chat question, not a `grill-me` run.

## Steps

### 0 — Calibrate

1. Detect, silently:
   - **Verification matrix**: commands that gate a change across every config
     (targets, feature flags, OS, host with and without each optional tool the
     change calls). Source: task runner (`just --list`, `Makefile`,
     `package.json` scripts), else native toolchain, plus CI config. Tests
     that nothing runs → add them to the matrix and record the gap. Use the
     full applicable matrix for high risk. A missing required tool leaves
     its check unverified.
   - **Authority docs**: see rule 1. None → README + public API + tests are
     the working contract; say so.
   - **Commit rules**: AGENTS.md, `CONTRIBUTING`, `git log` format.
   - **Pass rows**: one ledger row per pass — Exercise (step 1) and the six
     of step 4. Resolve skills as described in AGENTS.md. For Review, apply
     the built-in Review brief when `code-review` is unavailable.
2. Run the matrix on the target change. Red → friction finding for step 2;
   its fix becomes the first slice, so later slices can land green.
3. Ledger: read `references/ledger.md`, then resume the existing one or create
   it.
4. Scope = whole repo, or wider than one context window → read
   `references/slice-queue.md` and build the queue before step 1.
5. State matrix, baseline result, authority docs in one chat line. Before
   implementing a nontrivial change, apply TDD's boundary-assumption step.
   For unchecked invariants read [Soundness](references/soundness.md).

Round 1 range = target change's base..`HEAD`, so round 1 reviews the change
itself. Later rounds: commits landed since the previous round.

Done when the ledger holds scope, range, matrix with baseline result,
authority docs, and seven pass rows.

### 1 — Exercise

Run `dogfood` on the affected consumer behavior, with an independent
reviewer for a high-risk or broad cold walk (brief:
`references/pass-brief.md`); dogfood picks its own mode. Its fast-exit `N/A`
report → ledger row `N/A`; friction then comes from step 4 Review, pulled
forward.

Done when the friction report path is in the ledger.

### 2 — Triage and decide

Use the [finding format](references/pass-brief.md#finding-format). Accept a
behavioral defect for implementation after a concrete reproduction or failing
executable check demonstrates it. When reproduction is unsafe or impractical,
record concrete code evidence as a supported risk and account for it in the
convergence verdict. A hypothesis needs an experiment before it can drive a
fix.

Proceed on fixes covered by the user's intent. Present options, evidence, and
a recommendation for unresolved decisions; use `grill-me` only when decisions
depend on one another. Check each accepted fix against the authority docs.

Done when every finding has an accepted, rejected, or deferred disposition
with evidence. No fixable findings → step 4.

### 3 — Slice, test, commit

Split approved work into vertical slices (`to-tasks` when more than ~3). Each
slice: `tdd` for behavior changes → matrix (rule 2) → commit. The step 2
verdict carries through TDD. Its review belongs to step 4 here.
Red-baseline fix lands first; widest-blast-radius slice last. Approved fix
only partly achievable → re-gate when the gap changes the user's choice, else
record the residual in the commit body.

For an accepted consumer defect, promote the smallest reproduction into the
project's normal checks. Use the real interface and actual tooling, such as
Cargo with a disposable client and an unpacked package. Demonstrate the
original failure and the post-fix pass. Wire the fixture into a project-local
`just` recipe or equivalent and the applicable CI gate. If durable execution
is impractical, record what remains unverified and why.

Done when every accepted finding has a landed commit or a recorded decline,
and each consumer check has pre-fix and post-fix evidence or a named gap.

### 4 — Passes

Over the round's range (step 0). Run in-context passes (Soundness, Docs)
first, then use the Review brief over the resulting range with the reviewer
selected in Right-size.

| Pass | Runs in | Does |
|---|---|---|
| Review | by tier | apply the brief. Use `code-review` if available for ordinary code review |
| Soundness | here | change touches an invariant the toolchain won't check (unsafe/FFI, shared mutable state, concurrency, privilege, call-order lifecycle) → `references/soundness.md`; else row `N/A: no unchecked-invariant surface` |
| Simplify | combine with Review when practical | invokes `simplify` when the diff raises reuse, quality, or efficiency questions |
| Architecture | combine with Review when practical | invokes `improve-architecture` when boundaries or coupling change; gate an unresolved architectural decision |
| Test-health | `test-design-reviewer` (forks itself, read-only) | runs when affected checks are new, weakened, or show test-health concerns; args: repo path, range, findings path. Fixes → `references/test-health.md` |
| Docs | here | every behaviour change reaches every doc describing it: README, API docs, man page, `--help`, examples, changelog. Regenerate generated docs. Drift → `~/.config/agents/guard-ladders.md` *Docs drift* |

**Test-health stays clean.** Once a round's Test-health finds nothing
significant, later rounds row it `N/A: suite clean since round <n>, no tests
removed or weakened`. Reuse the first pass's evidence for the unchanged suite. Check added tests
against their TDD evidence. Before
writing that row, check the round's range; either check fails → run the pass:

1. Test count ≥ count recorded at the clean round (stack's list command, e.g.
   `cargo nextest list | wc -l`; record the count in the ledger row).
2. `git diff <range> -- <test paths>` has no removed line holding an
   assertion (`^-.*(assert|expect|should|check)`) unless the same hunk adds
   one at least as strict; no `#[ignore]`/skip/`only` added.

Each finding: **significant** = bug, coverage or contract gap, flaky or slow
test, reframing that deletes code or concepts, cohesion-map mismatch in a
file touched by > 25% of recent commits (`improve-architecture` step 1a). Doc
findings (stale, imprecise, or contradicting code) are cosmetic: fix them in
passing, but they never block convergence. Exception: doc so misleading that it
would frustrate a large share of users (wrong install, wrong core API usage,
claims a guarantee the code breaks) → significant. Else cosmetic or false
positive → one line in findings, no slice. When passes disagree, resolve the evidence and record any remaining risk.
Significant findings → step 2 for triage, then step 3 for accepted fixes.

Done when every pass row has its status and evidence or reason, and every
significant finding has a disposition. Use the status names in the ledger.

### 5 — Converge and close

Repeat affected parts of steps 3–4 within the review budget. Reuse a final-range
independent Review as convergence evidence where it covers the final behavior.
Use the convergence brief in `references/pass-brief.md` for remaining gaps.

Re-run affected consumer checks and use `dogfood re-eval <report>` when a
consumer report exists. Run the applicable final matrix on HEAD.

Converged = required checks green, tier's review evidence present, original
friction resolved or declined on evidence, zero open significant findings.
An unresolved serious safety risk blocks convergence even when reproduction
is impractical. At budget exhaustion report what remains open and surface
decisions needed to continue.

## Gates

Stop and hand the decision to the user at:

- authority-doc conflict (rule 1);
- unresolved product or architecture decision (steps 2 and 4);
- public safety-contract change (`references/soundness.md`);
- irreversible or outward-facing action: push, publish, delete, migration,
  dependency change outside the approved scope.

Form: AGENTS.md *Writing* gate rule. Record each verdict in the ledger. Between
gates, run autonomously.

## Done criterion

Close with the step 5 verdict and report:

1. Slices landed (commit subjects) and decisions with their durable homes.
2. Pass ledger with evidence, disposition, and any skipped or reused coverage.
3. Final matrix status, red stays red.
4. Convergence verdict, review provenance, and open findings with reasons.
5. Boundary results and durable consumer checks, with any gaps.

Keep the ledger and logs as evidence for resumption and retrospectives.

## Self-check

Before the closing report:

1. `git log --format=%s <range>`: every approved finding has a commit or a
   ledger decline.
2. Each `RAN` row names its skill or review method and links its evidence.
3. Each evaluative row names its reviewer and range. Missing required
   independent review keeps high-risk convergence open.
4. Last matrix run is on `HEAD`: its recorded commit equals `git rev-parse
   HEAD`.
5. Each decision the report names resolves: ADR path exists, or `git show`
   of the commit shows the rationale in its body.
