---
name: evolutionary-spike
description: Use when the right shape of a design, or whether it's worth building, can only be found by building it. Triggers on "spike N approaches", "explore the design space", "design bake-off", "prototype and pick", "is X worth building", "evolutionary spike". One obvious approach or a single throwaway → `tdd`.
---

# Evolutionary spike

## Overview

Settle a design or feasibility question by building: throwaway **spikes** in
parallel, independent review, eliminate losers while keeping their lessons,
converge on finalists, decide. One run = a **tournament**. Output = ADR on
`main` with a cost-benefit verdict; "don't build it" is a valid verdict.

Pipeline: `to-spec` (what) → this (which shape) → `tdd` (build it) → `harden`
(refine it). Name the next skill in the verdict; the user starts it.

## Tiers

Start at the smallest tier that answers the question. Escalate when spikes
disagree, or the choice is costly or irreversible. The user's tier choice and
spike count (total, clean-room included) override, up or down.

- **Light**: loop steps 1-3 and 5, 2-4 spikes. One agent may build several
  directed spikes; each clean-room spike gets its own agent. Self-review with
  `references/reviewer-brief.md` checks allowed (overrides `AGENTS.md`'s
  fresh-agent review); the findings doc's Confidence line says so. Gate says
  continue → escalate to Heavy.
- **Heavy**: full loop, one or more Refine rounds, fresh reviewer every round.

## Loop

Breadth first, then depth.

1. **Frame.** Set up the workspace (*Isolation*) and fill the findings doc's
   Question, Constraints (requirements, not solutions), Mechanisms and
   Contract. Contract = harness inputs + expected output format + verify
   commands; you define it, each spike implements it. Feasibility question
   ("is X worth it") → the current implementation is spike `baseline`, run on
   the same harness. User named no approaches → the mechanism list goes to the
   user for approval. Done when those four sections are filled and the list
   approved.
2. **Breadth sweep.** In parallel: one **directed** spike per listed
   mechanism, plus a few pure **clean-room** spikes to show where unanchored
   designers converge and to surface mechanisms nobody listed. Front-loading
   the sweep is what makes later convergence trustworthy. Done when every
   spike compiles, its tests pass, and its harness output is captured — or its
   failure is recorded in the findings doc.
3. **Converge.** Diff the harness outputs. Independent review of every spike
   (`references/reviewer-brief.md`). Each spike becomes finalist or
   eliminated, with why-lost, what-didn't-work and carry-forward lines. Present
   the gate report. Done when every spike has a status and the user chose
   continue or stop.
4. **Refine** (Heavy). **Informed** spikes iterate within the finalists. Clear
   convergence → one **capstone** spike combining the finalists' best parts;
   ambiguous → several finalists in parallel tracks until one wins or they
   settle into genuine trade-off axes. Review as in step 3, then the gate
   report. Done when the user chose continue (another Refine round with the
   named spikes) or stop.
5. **Decide.** Present the verdict for approval, then write the ADR. Done when
   *Stop and done* holds.

**Gate report** (end of Converge and of every Refine round):

1. Each spike built this round: finalist, or which finalist beat it and why.
2. Open axes: trade-offs the finalists still split on; each marked values call
   (user decides) or spikeable (another round could settle it).
3. Untried: listed mechanisms never built, and mechanisms clean-room spikes
   surfaced that no directed spike has explored.
4. Recommendation: **stop** when this round produced no new finalist, nothing
   spikeable is untried, and every open axis is a values call; else
   **continue**, naming the next spikes.

## Stop and done

Stop is the user's call at a gate report. After the user calls stop, the
tournament is done when:

1. Findings doc lists every spike id as finalist or eliminated, each eliminated
   one with why-lost and carry-forward lines, and a Verdict section.
2. Every spike's code and the findings doc are committed on their spike
   branches; `git status` is clean in every worktree.
3. User approved the verdict.
4. ADR written, every tier: `docs/adr/NNNN-<topic>.md`, next free number (no `docs/adr/` → start at
   `0001`), status proceed / don't-proceed / deferred. Names the chosen design,
   its impact on the codebase, and open items for the real build. Committed on
   `main`; `git show --name-only <adr-commit>` lists only the ADR.
5. Worktrees removed (`git worktree remove`); spike branches kept for the user
   to delete.

## Agents

- One agent per spike (Light exception in *Tiers*), dispatched in parallel,
  each scoped to its own files or worktree. Spike id = mechanism slug
  (`ring-buffer`, `clean-1`, `baseline`).
- Modes: **clean-room** (reads only the problem: `src`, spec; prior spikes and
  findings stay unread), **directed** (clean-room, built around one named
  mechanism), **informed** (given lessons + finalists to build on).
- Orchestrator (you) dispatches, digests reports, runs eliminations. Spike
  agents write all spike code; each review comes from a fresh agent (Light
  excepted).
- Briefs: `references/spike-brief.md`, `references/reviewer-brief.md`.

## Isolation

1. Find the repo's spike convention first: `git worktree list; git branch
   --list 'spike/*'; grep -ns spike .gitignore .git/info/exclude`. Found →
   use its dir as `<spike-dir>`. None → `<spike-dir>` = `.spike-workspace/`,
   added to `.git/info/exclude` (local; `main` stays untouched).
   `spike/<topic>` already exists → ask the user: resume that tournament, or
   pick a new topic name.
2. **Topic worktree**: `git worktree add <spike-dir>/<topic> -b spike/<topic>
   main`. Holds the findings doc and every additive spike. The main checkout
   stays on `main`.
3. **Additive** spike (preferred): new files only, placed where the build finds
   them without editing existing files (Rust: `examples/`, `tests/`,
   `benches/`). Additive spikes share the topic branch and diff side by side.
4. **Invasive** spike: edits any existing tracked file (`src/`, manifest,
   lockfile). Own worktree from `main`, so clean-room agents see no other
   spike: `git worktree add <spike-dir>/<spike-id> -b spike/<topic>-<spike-id>
   main`. Costlier to set up and compare → fewer spikes.

Worktrees under the spike dir share the object store, so spike commits are
durable in `.git` while `main` stays clean. Copies elsewhere failed: `cp -R`
with a stale `target/` hit 24GB and killed spikes, and a `/tmp` reaper deleted
a finished tournament's reports and patches.

## Commits and gates

Spike branches are local and never merge, so `AGENTS.md`'s trunk rules (every
commit green, one commit per finding, merge fast, a Skill call per commit)
cover only the ADR commit. Spike-branch commits: after each build, after each
review, and before each elimination, so every spike stays in history — red
builds included, with the failure noted in the findings doc. Message format:
`chore(spike): <topic> <what>`.

Capture a spike's lessons in the findings doc before deleting its files.

Gate (stop, present, recommend) at: approving the mechanism list, each gate
report, judgement-call eliminations, tier changes, the verdict.
Strictly-dominated spikes you cut yourself, with the reason in the findings
doc.

## Artifacts

**SPIKES NEVER TOUCH MAIN — code and findings both.** `main` is what every
clone carries forever; temporary work must not levy permanent tax. Only the ADR
crosses, and pushing it is gated.

- **Spike branches** `spike/<topic>` (+ `spike/<topic>-<id>` for invasive):
  spike code + findings doc, local only. Durable across `/clear` and session
  death.
- **Findings doc** `<topic>-findings.md` at the topic worktree root, from
  `references/findings-template.md`.
- **ADR**: see *Stop and done*. It must read without the spike branch.
- **Shipping a winner**: write it fresh against `main` to production quality.
  Spikes skip edge cases, docs and polish to get an answer; lessons transfer,
  code doesn't.

## Comparability

Every spike in a round runs the same deterministic harness with byte-identical
output, so results diff directly and honesty checks stay cheap. Harness
impossible (e.g. perf bake-off) → best deterministic comparison available
(fixed inputs, deterministic metrics), stated in the Contract.

## Self-check

Before each gate report:

1. `git -C <worktree> status` for each worktree. Uncommitted work → run its
   build and tests, record the result, commit.
2. `git -C <spike-dir>/<topic> ls-files` and `git worktree list`: every spike
   file and worktree belongs to a spike the findings doc lists as live or
   finalist. An eliminated spike's files reappeared (late-finishing agent) →
   delete them and commit.

Before done: a fresh agent reads only the ADR and states
the decision, the reason, and what's open. It needs the spike branch →
rewrite the ADR.

## Gotchas

- **A dead spike's work is on disk.** An agent that dies loses the ability to
  explain its work, not the work. Before writing a spike off, run its build and
  tests yourself: a green suite you ran beats any self-report. One spike
  written off as unverifiable held 1300 lines and 40 passing tests.
- **"Running" ≠ working.** Judge liveness by file mtimes on disk, not agent
  status. A stalled spike is usually rate-limited: resume it before killing it,
  since its transcript holds context a relaunch lacks.
- **jj repo** (`.jj/` exists): read `references/jj.md` before deleting any
  spike branch.
