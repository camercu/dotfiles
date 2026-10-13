---
name: harden
description: Use when user wants to build or refine something "properly", harden a change, run a multi-pass quality loop, evaluate an API as a real consumer, or says "do this properly", "full quality pass", "refine loop", "keep going until clean", "production-grade".
---

# Harden

## Overview

Take a change to a maintenance-first quality bar: exercise it as a consumer,
decide fixes with the user, land them test-first, then run review passes until
a full round finds nothing significant (**converged**). Harden sequences
specialist skills (`dogfood`, `grill-me`, `tdd`, `code-review`, `simplify`,
`improve-architecture`, `test-design-reviewer`); each owns its method. Harden
owns order, gates, run state, and the convergence proof.

Run state lives in a **ledger** on disk, so `/clear` and resume are safe.

## Rules (every phase)

Commits, fresh-agent review, and real Skill calls follow AGENTS.md
*Development process* and *Git*. Findings follow
`~/.config/agents/record-as-you-go.md`. Harden adds:

1. **Authority docs win.** Spec, ADR, design doc, `CONTEXT.md`, agent
   instructions, documented contract. A change that reverses one → gate: quote
   the conflict, implications, recommendation. Approved contract change →
   update every reference to it in the same slice; a half-updated doc
   contradicts itself.
2. **Slice green across the whole matrix.** Run the verification matrix after
   every slice, not only at the end. Slice done = green on every config it
   touches.
3. **Declines are results.** Evidence kills a plan (yours or the user's) → say
   so, with why. New evidence against a decline the user already chose → gate
   again, quoting the evidence. Record load-bearing decisions, declines
   included, in a durable home: ADR, or body of the nearest slice commit. No
   slice this run → ADR when load-bearing, else the closing report. Ledger
   only points at them.
4. **Evaluative passes run fresh; propagating passes run here.** Evaluative =
   judges the work: Exercise, Review, Simplify, Architecture, Test-health,
   convergence. Propagating = applies a known change: TDD slices, fixes,
   Soundness, Docs; these need to know what changed. Unable to spawn → run the
   evaluative pass here; its row reads `RAN (polluted)`.
5. **Invoking harden = consent** to every sub-skill and fresh-agent spawn it
   prescribes.

## Right-size

Blast radius sets ceremony; rules 1–5 hold at every size. Record each sizing
choice in the ledger.

- **Consumer surface** (public API, CLI, observable behaviour): full loop.
- **No consumer surface** (internal refactor, test, doc, lockfile): friction
  comes from diff review, not consumption. Passes that act on consumer surface
  → `N/A` in the ledger.
- **Infrastructure code**: Exercise = converge on the target (check mode while
  the host is unreachable) plus the verify playbook.
- **Agent count.** Default: one fresh agent per evaluative pass. Small diff
  where Review, Simplify, Architecture all look near-done → one agent carries
  all three (combined brief in `references/pass-brief.md`); each ledger row
  cites the shared result. Blast radius wider than one agent can hold → split
  by subsystem.
- A gate with one obvious option = one chat question, not a `grill-me` run.

## Steps

### 0 — Calibrate

1. Detect, silently:
   - **Verification matrix**: commands that gate a change across every config
     (targets, feature flags, OS, host with and without each optional tool the
     change calls). Source: task runner (`just --list`, `Makefile`,
     `package.json` scripts), else native toolchain, plus CI config. Tests
     that nothing runs → add them to the matrix, and a friction finding. A
     check that skips when its tool is missing counts red until run with the
     tool.
   - **Authority docs**: see rule 1. None → README + public API + tests are
     the working contract; say so.
   - **Commit rules**: AGENTS.md, `CONTRIBUTING`, `git log` format.
   - **Pass rows**: one ledger row per pass — Exercise (step 1) and the six
     of step 4. Pass skill absent from this session's skill list → row
     `SKIPPED: skill absent`.
2. Run the matrix on the target change. Red → friction finding for step 2;
   its fix becomes the first slice, so later slices can land green.
3. Ledger: read `references/ledger.md`, then resume the existing one or create
   it.
4. Scope = whole repo, or wider than one context window → read
   `references/slice-queue.md` and build the queue before step 1.
5. State matrix, baseline result, authority docs in one chat line.

Round 1 range = target change's base..`HEAD`, so round 1 reviews the change
itself. Later rounds: commits landed since the previous round.

Done when the ledger holds scope, range, matrix with baseline result,
authority docs, and seven pass rows.

### 1 — Exercise

Fresh agent invokes `dogfood` on the change (brief:
`references/pass-brief.md`); dogfood picks its own mode. Its fast-exit `N/A`
report → ledger row `N/A`; friction then comes from step 4 Review, pulled
forward.

Done when the friction report path is in the ledger.

### 2 — Decide ⟨gate⟩

Each friction finding → options with codebase evidence, a recommendation, and
a check against authority docs (rule 1). One finding's choice changes
another's options → `grill-me`; resolve those dependencies first. Independent
findings → one gate message, numbered. Prefer the option the code supports
over the elegant one. No fixable findings → note it, go to step 4.

Done when the user chose a fix, or decline, for every finding.

### 3 — Slice, test, commit

Split approved work into vertical slices (`to-tasks` when more than ~3). Each
slice: `tdd` → full matrix (rule 2) → commit. Step 2 verdict = tdd's plan
approval; tdd's review step = step 4 here, run once per round over the range.
Red-baseline fix lands first; widest-blast-radius slice last. Approved fix
only partly achievable → re-gate when the gap changes the user's choice, else
record the residual in the commit body.

Done when every approved finding maps to a landed commit or a recorded
decline.

### 4 — Passes

Over the round's range (step 0). Run in-context passes (Soundness, Docs)
first, then spawn the evaluative ones over the resulting range. Spawned
passes: brief from `references/pass-brief.md`.

| Pass | Runs in | Does |
|---|---|---|
| Review | fresh agent | invokes `code-review`; two lenses in the brief |
| Soundness | here | change touches an invariant the toolchain won't check (unsafe/FFI, shared mutable state, concurrency, privilege, call-order lifecycle) → `references/soundness.md`; else row `N/A: no unchecked-invariant surface` |
| Simplify | fresh agent | invokes `simplify` |
| Architecture | fresh agent | invokes `improve-architecture`; do-vs-decline = gate |
| Test-health | `test-design-reviewer` (forks itself, read-only) | args: repo path, range, findings path; you write its report to the findings file. Fixing its findings → `references/test-health.md` |
| Docs | here | every behaviour change reaches every doc describing it: README, API docs, man page, `--help`, examples, changelog. Regenerate generated docs. Drift → `~/.config/agents/guard-ladders.md` *Docs drift* |

Each finding: **significant** = bug, coverage or contract gap, flaky or slow
test, reframing that deletes code or concepts, cohesion-map mismatch in a
file touched by > 25% of recent commits (`improve-architecture` step 1a), doc
contradicting code. Else
cosmetic or false positive → one line in findings, no slice. Passes disagree
on a finding's rating → the higher rating wins. Significant findings → step 2
when a choice is open, else step 3 directly.

Done when every pass row reads `RAN`, `RAN (polluted)`, `N/A` (with the
surface it lacks), or `SKIPPED` (with reason), and every significant finding
is sliced or gated.

### 5 — Converge and close

Repeat steps 3–4 until one round yields zero significant findings. Converged
needs proof from a fresh agent: the convergence brief in
`references/pass-brief.md`, run over the final range. A Review agent that
already read the final range unprimed counts; spawn one only when Review ran
before the last slice landed.

Then re-run `dogfood re-eval <report>`: each original friction item resolved,
or declined with reason.

Done when the convergence agent reports zero significant findings and re-eval
shows no live friction the user did not decline. User stops the loop at a
gate → close with the open findings listed as deferred.

## Gates

Stop and hand the decision to the user at:

- authority-doc conflict (rule 1);
- fix selection (step 2);
- architecture do-vs-decline (step 4);
- public safety-contract change (`references/soundness.md`);
- irreversible or outward-facing action: push, publish, delete, migration,
  dependency change.

Form: AGENTS.md *Writing* gate rule. Record each verdict in the ledger. Between
gates, run autonomously.

## Done criterion

Run is done when step 5's criterion holds, and the closing report gives:

1. Slices landed (commit subjects) and decisions with their durable homes.
2. Pass ledger: the seven rows from step 0 — `RAN` (result, findings acted
   on or declined), `RAN (polluted)`, `N/A` (surface it lacks), `SKIPPED`
   (reason). A skill that declines by its own guardrails = `RAN (declined)`,
   with why.
3. Final matrix status, red stays red.
4. Convergence verdict quoted from the fresh agent, marked independent; or the
   significant findings deliberately deferred, with why.

Then delete `.harden/`.

## Self-check

Before the closing report:

1. `git log --format=%s <range>`: every approved finding has a commit or a
   ledger decline.
2. Each `RAN` row that names a skill → a Skill tool call exists in this
   context, or the pass's findings-file header lists the skill as invoked.
   Neither → row becomes `SKIPPED`.
3. Each evaluative `RAN` row ran in a fresh agent, or reads `polluted`.
4. Last matrix run is on `HEAD`: its recorded commit equals `git rev-parse
   HEAD`.
5. Each decision the report names resolves: ADR path exists, or `git show`
   of the commit shows the rationale in its body.
