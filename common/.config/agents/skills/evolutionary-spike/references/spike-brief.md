# Spike brief template

Fill the `{{slots}}`, keep one mode block, dispatch. `## Problem` is identical
for every spike in a round, so results compare. Keep the quality bar, honesty
and proof sections in every brief.

---

You are building throwaway spike `{{spike-id}}`. Work only in
`{{worktree-path}}` on branch `{{branch}}` (already created for you). Files in
scope: `{{new files, e.g. examples/<spike-id>.rs}}` (additive) or whatever
existing files the mechanism needs, manifest and lockfile included
(invasive); every other file stays as it is. Toolchain:
`{{how-to-run-tools}}`, run through that, not host binaries. The orchestrator
commits.

## Problem
{{one paragraph: the question being resolved, same for every spike}}

## Requirements
Meet all of these, or report which ones the mechanism cannot meet:
{{hard constraints stated as properties, not solutions — e.g. no unsafe,
stable toolchain, zero-alloc, perf bound}}

## Mode (keep one)
- **Clean-room:** read only `{{allowed: src, spec}}`, for the problem, not a
  solution. `{{forbidden: prior spikes, findings doc}}` hold prior designs;
  opening one anchors you. If you open one, say so in your report.
- **Directed:** clean-room rules, and build your design around
  `{{named mechanism}}`. If the mechanism can't meet a requirement, report that
  as a finding.
- **Informed:** read `{{finalists + findings}}` and build on them. State what
  you took from each, what you rejected, and why.

## Quality bar
Throwaway spike. Build the least code that answers {{the key question}} with
proof, then stop. Write tests that prove the core behaviour correct; writing
them after the code is fine, and edge cases are out of scope. This spike is
exempt from `AGENTS.md`'s `tdd` and `harden` steps; the fresh production build
runs them. Error handling, docs and refactoring belong to that build.

## Comparability harness
Run this scenario: {{deterministic demo — inputs + expected output}}. Produce
byte-identical deterministic output so results diff directly. Impossible →
use the best deterministic comparison you can and say why.

## Honesty
A "this loses" result is as valuable as a win. Report every regression
(alloc, `Rc`, unsafe, unstable feature, lost property, stub that fakes
behaviour) and every unmet requirement as a finding, at the size it really is.

## Proof
Compile, run, and test: {{verify commands / configs}}. Prove each key claim
with evidence (e.g. add a probe that must fail to compile, capture the exact
error, remove the probe). Paste the load-bearing output lines.

## Report
1. Interface / shape (key signatures).
2. Requirements met and unmet.
3. {{the key question}}, answered with proof.
4. Every wart.
5. Honest verdict against the alternatives.
6. All verification and test results.
