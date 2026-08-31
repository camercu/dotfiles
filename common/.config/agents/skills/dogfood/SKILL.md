---
name: dogfood
description: Use when user says "dogfood", "exercise as a consumer/user", "friction report", "consumer trial", "try it like a real user", or asks to re-run a prior friction report. Also runs as harden skill Phase 1 (Exercise then friction). Any software type — library, CLI, server/API, web UI, TUI.
---

# Dogfood

## Overview

Docs-first walkthrough, full public-surface coverage, adversarial misuse, producing a ranked friction report. Re-eval mode re-runs a prior report for a resolved / still-live delta.

Exercise target as a real consumer. Output = friction report, nothing else.
**Report-only: never edit target repo.** Fixes belong to harden phases 2-3 or the
user. All scratch work in `/tmp`.

## Modes

- **cold** (default): full run, passes 0-3.
- **re-eval `<prior-report>`**: rebuild consumers from the prior report's coverage
  matrix in fresh `/tmp`, re-walk, emit resolved / still-live / new delta. The
  re-sync *is* the convergence check.
- **contract-verify**: context already knows the internals but the change is narrow
  — a pretend-cold walk is dishonest ("answer only from docs" un-followable once you
  know the errno mapping), a fresh-subagent spawn too heavy. Drop the doc-innocence
  rule; instead treat every doc claim as an assertion + verify it *empirically
  against the real artifact* (run the binary, observe exit codes/output, compare to
  the documented contract). Truth = observed behavior, not what source lets you
  infer. Contradictions → `docs` findings.
- **fresh-subagent**: context contaminated (already worked target this session) *and*
  the surface wide enough that cold-walk innocence matters. Offer user: spawn a fresh
  agent whose prompt = only "dogfood per docs at <path>", collect report back.
  Default without contamination: run inline w/ the discipline rule (below).

## Safety rails (every pass)

- Sandbox: fake `$HOME`, throwaway dirs, local instances in `/tmp`. Never run
  destructive/stateful surface (delete, migrate, publish, system config) against the
  real environment — simulate in scratch.
- Outward-facing action (real network service, publish, telemetry) → STOP, ask user
  first.
- Un-sandboxable surface (root, hardware, paid API) → honest-remainder list, never
  forced, never silently skipped.

## Pass 0 — Enumerate surface

**Fast-exit:** change touches *no* consumer-observable surface (internal test,
refactor, doc, lockfile)? Emit a one-line **N/A report** (target, change scope,
"friction source = diff review") + stop; don't enumerate the target to learn the
change touched none of it. Scope to *the change* — a big target w/ a doc-only diff
still fast-exits. (No change under review = full-target run.)

Machine-enumerate when tooling exists, else docs-declared surface. Write the
inventory checklist to scratch — becomes the coverage tracker.

| Type | Consumer = | Surface from | Drive via |
|---|---|---|---|
| Library | small client project(s) | public-surface tool / exports / API docs | compile + run |
| CLI | shell scripts, real invocations | recursive `--help`, man page | run binary |
| Server/API | client scripts vs local instance | OpenAPI / route docs | requests |
| Web UI | browser walkthrough | pages/flows from docs | claude-in-chrome |
| TUI | scripted pty session | keybinding/command docs | tmux / expect |

Unknown type → derive the three columns from the entry doc, say so. Use `run`/`verify`
skills for launching; don't re-derive.

## Pass 1 — Docs-first cold walk

Consume like a stranger. Three rules:

1. **Ladder**: entry doc (README/getting-started/man intro) → reference docs (API
   docs, `--help`) → source/tests only when docs fail. **Every rung-drop = a logged
   finding** ("docs couldn't answer X" + which doc should have). Isolates doc issues.
2. **Verbatim execution**: run/compile every doc snippet exactly as written. A stale
   example must fail loudly, not get skimmed past.
3. **Claims = assertions**: every doc claim ("works without config", "exits nonzero
   on failure") gets verified, not read.

Discipline rule (inline mode): answer only from docs. Caught using session knowledge
not in docs → that IS a doc-gap finding.

Log rough edges too, not just docs clarity: surprising defaults, ceremony, unhelpful
errors, awkward API shapes — `ux-devex` findings.

## Pass 2 — Coverage

1. **Realistic consumers first**: a few small projects, each a plausible use case
   mapped to surface regions. Ergonomics friction only surfaces in realistic use.
2. **Sweep pass**: minimal probes for inventory items no consumer touched. Sweep
   finds crashes; consumers find UX — need both.
3. **Honest remainder**: unexercised items + why.

## Pass 3 — Adversarial misuse

Kept last — cold walk stays uncontaminated by breaker mindset. Misuse: wrong call
order/state, boundary + garbage inputs, ignored guards/returns, violated
preconditions, concurrent use. Misuse that runs + silently does wrong instead of
being rejected = `soundness` finding (feeds harden Soundness pass).

## Friction report

**Open the file at pass 0, not at the end.** Write Context immediately, then
**append each finding the moment it is found** — evidence (command, output,
file:line) with it, before the next probe starts. Never batch findings in
context: session limit / compaction / crash kills the pass and every finding
in it. A half-written report on disk beats a perfect one that never got typed.
Consumer code + repro commands stay in scratch, referenced by path, so a later
run rebuilds them without re-deriving. Re-eval mode depends on this too.

Write to scratch, tell user the path. Sections in order:

1. **Context**: target name/version/commit, date, mode, scratch path.
2. **Coverage matrix**: consumer → surface regions. Describe each consumer concretely
   enough to rebuild from scratch (re-eval depends on it). Detail scales to surface —
   don't inflate a 1-line change into a full-target inventory.
3. **Findings**, severity-ranked (blocker/high/medium/low). Each tagged: category
   (`docs` | `ux-devex` | `bug` | `soundness`), provenance (doc section or consumer
   file:line), **inherent-to-design vs fixable**.
4. **Re-eval only**: resolved / still-live / new-since.
5. **Honest remainder**: unexercised + why.
6. **Doc-ladder escalations**: every forced source-read = the doc-gap list.

Ranked findings, not vibes. The report is the deliverable; conversation summary just
points at it.
