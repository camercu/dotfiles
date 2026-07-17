# Spike-agent brief template

Fill the `{{slots}}`, pick ONE mode block, dispatch. Keep `## Problem` IDENTICAL
across every agent in a round (comparability). Adapt wording with judgment; never
drop the honesty + proof clauses.

---

You are building throwaway spike `{{id}}` in `{{repo}}` on branch `{{branch}}`.
Do NOT switch branches, commit, or push. Toolchain: `{{how-to-run-tools}}` (use it,
not host binaries). Create ONLY `{{artifact-path}}`; touch nothing else.

## Problem
{{one-paragraph problem statement — the thing being resolved, same for all agents}}

## Requirements (satisfy all, or report honestly which the mechanism CANNOT)
{{hard constraints as REQUIREMENTS, not solutions — e.g. safety property, perf
bound, no_std, zero-cost, stable-toolchain, no-unsafe. State the property; do not
prescribe how.}}

## Mode — pick ONE
- CLEAN-ROOM: Do NOT read `{{forbidden-files: prior spikes + findings doc}}` — I
  want your approach unanchored. You MAY read `{{allowed: src/spec}}` for the
  problem, not the solution. If you see a forbidden file, stop and say so.
- DIRECTED (space-exhaustion): build your design AROUND `{{named mechanism}}`.
  Same clean-room forbidden list. If the mechanism can't meet a requirement, that
  is a first-class finding — report it, don't force it.
- INFORMED: read `{{finalists + findings}}` and build on them. Take/reject
  explicitly; state what you took from each and why.

## Comparability harness
Same scenario for all: {{deterministic demo — inputs + expected output}}. Produce
BYTE-IDENTICAL deterministic output so files diff directly (unless impossible →
best deterministic comparison you can, and say why).

## Honesty mandate
A negative "this loses" result is valuable. Never fake a win, hide a regression
(alloc/`Rc`, unsafe, unstable feature, lost property, a lying stub), or oversell.
If a requirement is unmet, that's a first-class finding, not a thing to paper over.

## Proof, not claims
Compile AND run: {{verify commands / configs}}. PROVE key claims with evidence,
not assertion (e.g. add a probe that must fail to compile, capture the exact
error, then remove it). Paste the load-bearing output lines.

## Report back
(1) interface/shape (key signatures); (2) what it satisfies / can't; (3) THE KEY
QUESTION: {{the decisive property}} — answered with proof; (4) every wart named;
(5) honest verdict vs the alternatives; (6) all verification results.
