---
name: evolutionary-spike
description: Use when the right SHAPE or the VIABILITY of something is genuinely unknown and must be BUILT to know. Triggers on "spike N approaches and compare", "explore the design space", "which interface/shape/mechanism is best", "prototype and pick", "is it worth building X", "do benefits outweigh costs", "design bake-off", "run a spike tournament", "evolutionary spike". NOT for a single quick throwaway with no comparison, and not when one approach is already obvious (use Plan or tdd there).
---

# Evolutionary Spike

## Overview

Resolves a hard design or feasibility question empirically: many throwaway prototype spikes built in parallel (clean-room plus informed agents), reviewed independently, dominated ones eliminated while their lessons are captured, converging to finalists and a synthesized capstone.

Build-to-know loop. Hard design/feasibility question, several viable answers,
can't settle by reasoning → build throwaway prototype spikes, compare, eliminate,
converge, decide. Output = ADR (lands on main) + findings doc (spike branch only)
w/ cost-benefit verdict. Verdict may = "don't build it" — valid outcome.

## When

- Design bake-off: which shape/interface/mechanism best.
- Feasibility: worth building? benefits > costs? Build spike to see for real.
- Pipeline: [to-spec = what] → THIS [= which shape] → [tdd = build real] →
  [harden = refine]. Spikes throwaway, NOT tdd'd. Name neighbors, don't auto-invoke.
- Sibling to harden (shared discipline: reviewer independence, gates,
  commit-to-preserve, capture decisions, reverse own calls on evidence, finding=lead).
  Different phase/output → standalone skill, not a harden mode.
- NOT: one obvious approach → Plan/tdd. Single quick throwaway, no compare → not this.

## Tiers (adaptive)

Default smallest tier that answers question. Escalate on signal (spikes disagree /
costly / irreversible). USER forces any tier on demand — override beats heuristic
(both up and down).

- **Light**: 1 round, 2-4 spikes, maybe 1 agent builds the variants, 1 review,
  short findings note, verdict. Self-review allowed ONLY at this smallest tier
  (disclose reduced confidence).
- **Heavy tournament**: multi-round, clean-room + informed, fresh independent
  review per round, strict eliminate+lessons, capstone synthesis, ADR.

## Loop — BREADTH first, THEN depth

1. **FRAME.** Question + hard constraints (as REQUIREMENTS, not solutions) +
   honesty/proof contract. Write findings-doc header.
2. **BREADTH SWEEP** (space-exhaustion, front-loaded). Parallel clean-room agents:
   - space-exhaustion agents: one per KNOWN way to build it (mechanism/region).
   - + small number PURE unanchored clean-room: reveal where convergence points,
     surface a region you didn't enumerate.
   Front-load so later convergence is trustworthy (blind-spot guarded up front).
3. **CONVERGE.** Independent review. Capture lessons per candidate: why-lost +
   what-didn't-work + carry-forward tidbits/leads. Name finalists / promising region.
4. **REFINE** (informed generation). Iterate within survivors. Breadth ∝
   1/convergence-clarity: overwhelming convergence → single capstone track;
   ambiguous → carry MULTIPLE finalists in parallel tracks until one wins or they
   stabilize as genuine axes. Independent review to fixpoint.
5. **DECIDE.** Findings doc + ADR: chosen design, IMPACT on the real codebase,
   cost-benefit / net-positive verdict, open items for the real build. Or "don't build".
   ADR crosses to main; findings + spike code stay on the spike branch. Ship a winner
   as fresh production code, never merged spike code (see Artifacts).

## Agents

- Each spike = throwaway agent. Dispatch in PARALLEL. Scope each to its own
  artifact (own file/branch) so concurrent builds don't collide.
- Modes: **clean-room** (forbid reading prior spikes + findings; explicit
  forbidden-file list) / **informed** (given accumulated lessons + finalists to
  build on) / **directed** (build around one named mechanism).
- Convergence across INDEPENDENT clean-room agents = first-class signal (N unanchored
  designers landing on same shape = strong evidence). Heavy tier: spend agents to
  test convergence deliberately.
- Reviewer ≠ author. Independence absolute EXCEPT smallest tier.
- Orchestrator (you) never authors spikes — dispatch, digest reports, drive elimination.
- Briefs = fill-in templates: `references/spike-brief.md`, `references/reviewer-brief.md`.
  Adapt with judgment.

## Isolation

- **Additive (default, prefer):** standalone new file, no `src/` edits. Coexist on
  one branch, parallel-safe by file-scope, diff side-by-side. A spike expressible as
  a standalone example is cheaper AND better isolated.
- **Invasive (must edit `src/` to compile):** own git worktree/branch (Agent
  `isolation: "worktree"`), `spike/<topic>-<variant>`. Pricier to set up + compare →
  favor smaller N; comparability harness matters more here.

**WHERE: worktrees under a git-excluded dir IN the repo.** Look for the repo's
existing one first (`.spike-workspace/`, `.spikes/` — check `.gitignore`); create and
ignore one only if absent. `git worktree add .spike-workspace/<variant> -b
spike/<topic>-<variant>`.

NEVER copy the repo to `/tmp`. Measured on one 123MB repo: worktree 1.5MB, `cp -R`
123MB, and `cp -R` with a stale `target/` 24GB — which killed three arms twice. And
`/tmp` is NOT durable: a reaper took every report and patch from a finished
tournament. A worktree shares the object store, so arm commits are durable in the
repo's own `.git` while the tree stays untracked and main stays clean.

## Gates

Autonomous between decisions: dispatch, review, digest, verify.
Gated (stop + present): **eliminations** (recommend + justify; user approves — but
auto-cut STRICTLY-dominated candidates with a logged reason, gate only judgment
calls); **round/tier transitions**; **final verdict**.
Commits AUTOMATIC after each review pass and before each elimination — preserve every
spike in git history for recovery. They land on the SPIKE BRANCH, never main, and are
never pushed. Only an ADR reaches main, and pushing that is gated (outward-facing).
Capture lessons BEFORE deleting anything. Always.

## Stop

Stop generating → move to decide when any fire: convergence fixpoint / space
exhausted / diminishing returns (new round yields only variants that map to finalists
or lose) / decision-ready (finalists bracket the open axes, rest is a values call).
Skill PROACTIVELY recommends stopping — don't spike forever. Premature-stop guard:
don't stop while spikes still disagree on a fundamental property, or a whole region is
visibly untried (mostly satisfied by the front-loaded breadth sweep).

## Artifacts

**SPIKES NEVER TOUCH MAIN — code and findings both.** Spikes are temporary by
definition; main is what every downstream clone/fork carries forever. Temporary work
must not levy permanent tax. Only the ADR crosses.

- **Spike branch**: `spike/<topic>`. Holds spike code AND findings doc. Auto-committed,
  NEVER merged, never pushed. A branch is durable (survives /clear, session death, tmp
  reaper) without taxing main — that is why the checkpoint lives there, not in `/tmp`.
  Scratch dirs under `/tmp` are NOT durable: reaped without warning, taking every
  report and patch with them.
- **Findings doc**: `<topic>-findings.md`, ON THE SPIKE BRANCH. LIVING record that
  DOUBLES AS the resumable checkpoint. Skeleton = `references/findings-template.md`.
  Keep ephemeral orchestration bits (in-flight agent IDs) OUT.
- **ADR**: `docs/adr/NNNN-*.md` — the ONLY spike output that lands on main. Decision +
  impact analysis + cost-benefit/net-positive verdict + open items. Status: proceed /
  don't-proceed / accepted-but-deferred. Must STAND ALONE: reader gets the lesson
  without the spike branch, which may be gone.
- **Shipping a winner**: write it FRESH against main, to production quality. Never
  merge or cherry-pick spike code. Spikes are built to answer a question, not to a
  shipping bar — no tests, no edge cases, no docs, shortcuts taken to get an answer
  fast. Copying wholesale imports that debt. Lessons transfer; code does not.

## Comparability

Deterministic byte-identical demo harness REQUIRED unless genuinely impossible (e.g.
perf bake-off) → then flex to the best comparability available (deterministic metrics,
fixed inputs). Identical demos make diffing + honesty-checking cheap.

## Gotchas

- **Honesty mandate** (every brief): a negative "this loses" result is valuable; never
  fake a win, hide a regression (Rc, unsafe, unstable feature, lost property), or
  oversell. An unmet requirement = a first-class finding.
- **Zombie agents**: parallel spike agents can finish LATE (after a session-limit
  reset) and re-create deleted spike files — even from their own backups. Before each
  commit, re-verify the tree and remove strays so an eliminated design can't resurrect.
- **A dead agent's uncommitted work is NOT lost.** It is on your filesystem. Read it,
  build it, test it, commit it yourself. An arm that dies mid-run loses the ability to
  EXPLAIN its work, not the work. Wip-commit rules exist to save you the recovery, not
  because uncommitted means gone. Before writing off any arm: `git -C <worktree> status`,
  then run its tests. Recovered 1300 lines and 40 passing tests from an arm that had
  been declared unverifiable.
  Never call an arm's code unverifiable while the compiler and its tests can still run.
  That inverts the tournament's own rule: an arm's self-report is the weak evidence, and
  a green suite you ran yourself is the strong evidence.
- **"Running" is not "working".** Check disk mtimes, not agent status, to tell a live
  arm from a stalled one. And a stalled arm is usually rate-limited rather than dead:
  resume it before you kill it, because its transcript carries context no relaunch has.
- **Check for the repo's existing spike convention BEFORE inventing one.** One
  `grep spike .gitignore` would have found `/.spike-workspace`, a `spike/*` branch, and
  a whole prior tournament's worktrees still on disk. Missing it cost a lost
  tournament. Repos that have run this skill already carry its scaffolding.
- **Colocated jj: deleting a spike branch can abandon its commits.** `git branch -D
  spike/x` drops the ref; jj's next import sees the commits as unreachable and abandons
  them — including any main-line commit that branch happened to point at. Recover with
  `jj op log` + `jj op restore <op>`; nothing is lost if you notice. Prefer
  `jj bookmark delete`, or verify `jj log` right after any `git branch -D`.
- Self-review is polluted by author bias — disclose it and weight it below an
  independent review; never let it stand as the final verdict above the smallest tier.
