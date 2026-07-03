---
name: dogfood
description: Exercise software as real consumer would — docs-first walkthrough, full public surface coverage, adversarial misuse — producing a ranked friction report. Works for any software type (library, CLI, server/API, web UI, TUI). Use when user says "dogfood", "exercise as a consumer/user", "friction report", "consumer trial", "try it like a real user", or as harden skill Phase 1 (Exercise → friction). Re-eval mode re-runs a prior report for a resolved/still-live delta.
---

# Dogfood

Exercise target as real consumer. Output = friction report, nothing else.
**Report-only: never edit target repo.** Fixes belong to harden phases 2-3 or
user. All scratch work in `/tmp`.

## Modes

- **cold** (default): full run, passes 0-3 below.
- **re-eval `<prior-report>`**: rebuild consumers from prior report's coverage
  matrix in fresh `/tmp`, re-walk, emit resolved / still-live / new delta.
  Re-sync of consumers = the convergence check.
- **fresh-subagent**: when context contaminated (already worked on target this
  session), cold walk loses value — agent knows what docs never said. Offer
  user: spawn fresh agent whose prompt = only "dogfood per docs at <path>",
  collect report back. Default without contamination: run inline with
  discipline rule (below).

## Safety rails (every pass)

- Sandbox: fake `$HOME`, throwaway dirs, local instances in `/tmp`. Never run
  destructive/stateful surface (delete, migrate, publish, system config)
  against real environment — simulate in scratch.
- Outward-facing action (real network service, publish, telemetry) → STOP, ask
  user first.
- Un-sandboxable surface (root, hardware, paid API) → honest-remainder list,
  never forced, never silently skipped.

## Pass 0 — Enumerate surface

Machine-enumerate when tooling exists; else docs-declared surface. Write
inventory checklist to scratch dir — becomes coverage tracker.

| Type | Consumer = | Surface from | Drive via |
|---|---|---|---|
| Library | small client project(s) | `cargo public-api` / exports / API docs | compile + run |
| CLI | shell scripts, real invocations | recursive `--help`, man page | run binary |
| Server/API | client scripts vs local instance | OpenAPI / route docs | requests |
| Web UI | browser walkthrough | pages/flows from docs | claude-in-chrome |
| TUI | scripted pty session | keybinding/command docs | tmux / expect |

Unknown type → derive three columns from entry doc, say so in report. Use
`run`/`verify` skills for launching; don't re-derive.

## Pass 1 — Docs-first cold walk

Consume like stranger. Three rules:

1. **Ladder**: entry doc (README/getting-started/man intro) → reference docs
   (API docs, `--help`) → source/tests only when docs fail. **Every rung-drop
   = logged finding**: "docs couldn't answer X" + which doc should have.
   This isolates doc issues.
2. **Verbatim execution**: run/compile every doc snippet exactly as written.
   Stale example must fail loudly, not get skimmed past.
3. **Claims = assertions**: every doc claim ("works without config", "exits
   nonzero on failure") gets verified, not read.

Discipline rule (inline mode): answer only from docs. Caught using session
knowledge not in docs → that IS a doc-gap finding.

Log rough edges too, not just docs clarity: surprising defaults, ceremony,
unhelpful errors, awkward API shapes — `ux-devex` findings.

## Pass 2 — Coverage

1. **Realistic consumers first**: few small projects, each plausible use case,
   each mapped to surface regions. Ergonomics friction only surfaces in
   realistic use. Record region mapping in coverage matrix.
2. **Sweep pass**: minimal probes for inventory items no consumer touched.
   Sweep finds crashes; consumers find UX — need both.
3. **Honest remainder**: list unexercised items + why.

## Pass 3 — Adversarial misuse

Kept last — cold walk stays uncontaminated by breaker mindset. Try to misuse:
wrong call order/state, boundary + garbage inputs, ignored guards/returns,
violated preconditions, concurrent use. Misuse that runs and silently does
wrong instead of being rejected = `soundness` finding (feeds harden Soundness
pass).

## Friction report

Write to scratch dir, tell user the path. Sections, in order:

1. **Context**: target name/version/commit, date, mode, scratch path.
2. **Coverage matrix**: consumer → surface regions. Must describe each
   consumer concretely enough to rebuild from scratch (re-eval depends on it).
3. **Findings**, severity-ranked (blocker/high/medium/low). Each tagged:
   category (`docs` | `ux-devex` | `bug` | `soundness`), provenance (doc
   section or consumer file:line), **inherent-to-design vs fixable**.
4. **Re-eval only**: resolved / still-live / new-since.
5. **Honest remainder**: unexercised + why.
6. **Doc-ladder escalations**: every forced source-read = the doc-gap list.

Ranked findings, not vibes. Report is the deliverable; conversation summary
points at it.
