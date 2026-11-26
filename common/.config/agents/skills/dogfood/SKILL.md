
---
name: dogfood
description: Use when user says "dogfood", "exercise as a consumer/user", "friction report", "consumer trial", "try it like a real user", or asks to re-run a prior friction report. Also runs as harden skill Phase 1 (Exercise then friction). Any software type — library, CLI, server/API, web UI, TUI.
---

# Dogfood

## Overview

Docs-first walkthrough, full public-surface coverage, adversarial
misuse, and interface-specific audits, producing a ranked friction
report. Re-eval mode re-runs a prior report for a resolved / still-live
delta.

Exercise target as a real consumer. Output = friction report, nothing
else.

**Report-only: tracked files of the target repo stay untouched.**
Fixes belong to harden phases 2-3 or the user. Scratch work and the
report go under `.scratch/dogfood/<run>/` (AGENTS.md *Working files*).

## Modes

- **cold** (default): full run, passes 0-4.
- **re-eval `<prior-report>`**: rebuild consumers from the prior
  report's coverage matrix in a fresh `.scratch/dogfood/<run>/`,
  re-walk, emit resolved / still-live / regressed / new delta.
  The re-sync *is* the convergence check.
- **contract-verify**: context already knows the internals but the
  change is narrow — a pretend-cold walk is dishonest ("answer only
  from docs" un-followable once you know the errno mapping), a
  fresh-subagent spawn too heavy. Drop the doc-innocence rule;
  instead treat every doc claim as an assertion + verify it
  *empirically against the real artifact* (run the binary, observe
  exit codes/output, compare to the documented contract).
  Truth = observed behavior, not what source lets you infer.
  Contradictions → `docs` findings.
- **fresh-subagent**: context contaminated (already worked target
  this session) *and* the surface wide enough that cold-walk
  innocence matters. Offer user: spawn a fresh agent whose prompt =
  only "dogfood per docs at `<path>`", collect report back.
  Default without contamination: run inline with the discipline
  rule below.

## Safety rails (every pass)

- Sandbox: fake `$HOME`, throwaway dirs, local instances in `/tmp`.
  Never run destructive/stateful surface (delete, migrate, publish,
  system config) against the real environment — simulate in scratch.
- Outward-facing action (real network service, publish, telemetry)
  → STOP, ask user first.
- Un-sandboxable surface (root, hardware, paid API)
  → honest-remainder list, never forced, never silently skipped.

## Pass 0 — Enumerate surface

**Fast-exit:** change touches *no* consumer-observable surface
(internal test, refactor, doc, lockfile)? Emit a one-line **N/A report**
(target, change scope, "friction source = diff review") + stop.

Scope to *the change* — a big target with a doc-only diff still
fast-exits when the diff changes no consumer-facing claims,
instructions, or examples. No change under review = full-target run.

Machine-enumerate when tooling exists, else docs-declared surface.
Write the inventory checklist to scratch — becomes the coverage
tracker.

| Type | Consumer = | Surface from | Drive via |
| --- | --- | --- | --- |
| Library | Small client project(s) | Public-surface tool / exports / API docs | Compile + run |
| CLI | Shell scripts, real invocations, pipelines | Recursive `--help`, man page | Run binary |
| Server/API | Client scripts vs local instance | OpenAPI / route docs | Requests |
| Web UI | Browser walkthrough | Pages/flows from docs | Browser driver |
| TUI | Scripted PTY session | Keybinding/command docs | tmux / expect |

Unknown type → derive the three columns from the entry doc, say so.
Launch via the `run` skill.

For products exposing multiple interface types, inventory each
applicable consumer surface and the workflows crossing those surfaces.

For CLI targets, include documented arguments, flags, configuration,
input/output formats, exit statuses, and shell-composition workflows
in the inventory. Derive detailed CLI audit coverage in pass 4.

## Pass 1 — Docs-first cold walk

Consume like a stranger. Three rules:

1. **Ladder:** entry doc (README/getting-started/man intro) →
   reference docs (API docs, `--help`) → source/tests only when
   docs fail. **Every rung-drop = a logged finding** ("docs couldn't
   answer X" + which doc should have). Isolates doc issues.
2. **Verbatim execution:** run/compile every in-scope doc snippet
   exactly as written. A stale example must fail loudly, not get
   skimmed past.
3. **Claims = assertions:** every in-scope doc claim ("works without
   config", "exits nonzero on failure") gets verified, not read.

Discipline rule (inline mode): answer only from docs. Caught using
session knowledge not in docs → that IS a doc-gap finding.

Log rough edges too, not just docs clarity: surprising defaults,
ceremony, unhelpful errors, awkward API shapes, awkward output
formats, and unnecessary shell workarounds — `ux-devex` findings.

For CLI targets, attempt the documented workflows using the command
line and ordinary shell tools. Record any need to inspect source,
reverse-engineer output, or invent parsing workarounds.

## Pass 2 — Coverage

1. **Realistic consumers first:** a few small projects, each a
   plausible use case mapped to surface regions. Ergonomics friction
   only surfaces in realistic use.

2. **Sweep pass:** minimal probes for inventory items no consumer
   touched. Sweep finds crashes; consumers find UX — need both.

3. **Rust library:** run actual Cargo commands from disposable
   consumer crates. For shipping behavior, depend on an unpacked
   `cargo package` archive or the released crate. Exercise relevant
   default, no-default, and supported feature combinations and
   documented examples. Use fresh consumer and target dirs,
   isolated runtime config and home where relevant, and record
   any shared Cargo cache or toolchain.

4. **CLI:** use actual command invocations, shell scripts, pipelines,
   files, and independent data consumers. Exercise representative
   human-readable, plain-text, structured, tabular, and streaming
   workflows where supported or required by the consumer's goal.
   Capture stdout, stderr, exit status, and resulting side effects
   separately. Record composition friction and preserve transcripts
   for `cli-audit`.

5. **Honest remainder:** unexercised items + why.

## Pass 3 — Adversarial misuse

Kept after consumer walkthroughs — cold walk stays uncontaminated
by breaker mindset.

Misuse: wrong call order/state, boundary + garbage inputs, ignored
guards/returns, violated preconditions, concurrent use.

For CLI targets, include malformed arguments and data, ambiguous
targets, interrupted processes, non-interactive execution, early
downstream termination, and repeated invocation where applicable.

Misuse that runs + silently does wrong instead of being rejected =
`soundness` finding (feeds harden Soundness pass).

## Pass 4 — Interface-specific audits

Invoke the applicable interface-specific audit after consumer
walkthroughs and adversarial misuse:

| Interface | Audit |
| --- | --- |
| CLI | `cli-audit` in implementation mode |
| Interactive GUI or TUI | `ux-audit` |
| Library or server/API without an applicable UI | No interface-specific audit |

For products with multiple interface types, invoke each applicable
audit for its respective surface.

Scope the audit to the consumer surface under review. For re-eval
runs, pass the prior audit report where available and use the
corresponding re-evaluation procedure. For narrow contract-verify
runs, audit the affected workflows and shared contracts.

Use a fresh reviewer for substantial interface changes where
available. Record reviewer independence and limitations.

Pass to the auditor:

- Target revision and execution environment.
- Scope and public-surface inventory.
- Consumer projects, scripts, fixtures, and reproduction commands.
- Workflow transcripts and observed behavior.
- Existing findings and unverified coverage.
- Prior audit reports when re-evaluating.

Reuse equivalent observed evidence for the same revision,
configuration, and workflow rather than repeating probes.

The interface-specific audit owns its design criteria and coverage
requirements. Dogfood owns the consumer trial and consolidated
friction report.

For CLI targets, `cli-audit` owns systematic assessment of command
grammar, conceptual integrity, discoverability, grep-ability, output
formats, structured schemas, shell composition, process-boundary
contracts, safety, and compatibility.

Incorporate audit findings into the friction report. Consolidate
duplicates under their shared cause and retain the applicable
evidence, severity, and reproduction.

Link the audit report and carry forward all unverified coverage.
Record unavailable audit execution with its reason.

## Friction report

Open the report at pass 0 and fill it per
`~/.config/agents/record-as-you-go.md`.

Re-eval mode rebuilds consumers from the scratch paths it records.

Write to scratch, tell user the path. Sections in order:

1. **Context:** target name/version/commit, date, mode, scratch path,
   and execution environment.

2. **Coverage matrix:** consumer → surface regions. Describe each
   consumer concretely enough to rebuild from scratch (re-eval
   depends on it). Detail scales to surface — don't inflate a
   1-line change into a full-target inventory.

3. **Findings**, severity-ranked (blocker/high/medium/low).
   Each tagged: category (`docs` | `ux-devex` | `bug` |
   `soundness`), provenance (doc section or consumer file:line),
   **inherent-to-design vs fixable**.

   For a defect, include the affected contract, exact consumer
   command and setup, expected and actual result (including exit
   status where applicable), and the smallest fixture that
   reproduces it. Link scratch files so harden can turn the
   reproduction into a repo-local regression check.

4. **Interface-specific audits:** applicable skills, report paths,
   scope, findings incorporated, evidence reused, and unverified
   coverage. Consolidate findings in section 3 rather than
   duplicating them here.

5. **Re-eval only:** resolved / still-live / regressed / new-since.

6. **Honest remainder:** unexercised surfaces, contracts, environments,
   and audits + why.

7. **Doc-ladder escalations:** every forced source-read = the doc-gap
   list.

Ranked findings, not vibes. The report is the deliverable;
conversation summary just points at it.

## Done criterion

Done when:

1. Every in-scope public-surface item has consumer evidence or an
   explicit honest-remainder entry.
2. Every in-scope documentation example and claim has an observed
   result or an explicit unverified status.
3. Every inventoried consumer has reproducible setup and execution
   instructions in scratch.
4. Adversarial misuse coverage accounts for applicable failure modes.
5. Every applicable interface-specific audit has a linked report or
   explicit unverified status and reason.
6. Every finding has severity, category, provenance, impact,
   evidence, and a reproducible case or explicitly identified
   design-derived basis.
7. Every prior finding has a disposition in re-eval mode.
8. Tracked target files remain unchanged.
9. The chat reply gives the report path, finding counts by severity,
   and outstanding coverage.

## Self-check

1. Compare the public-surface inventory against consumer coverage.
   Every item has observed evidence or an honest-remainder entry.
2. Compare documentation claims and examples against observed
   results. Every forced source-read appears in the report.
3. Inspect reproduction commands and fixtures. Every observed
   defect can be reproduced from its recorded setup.
4. Compare applicable interfaces against the pass 4 audit table.
   Every required audit has a report or an explicit unverified status.
5. Reconcile interface-specific audit findings with the consolidated
   friction report. Every finding is retained or accounted for
   through consolidation.
6. For CLI targets, inspect captured output, exit statuses, and
   consumer results. Every claimed process-boundary pass has
   observed evidence.
7. Compare severity totals, re-evaluation dispositions, and honest
   remainder with the final report.
8. Compare tracked-file state before and after the run. Preserve
   pre-existing user changes; all dogfood-created files remain
   in scratch.
