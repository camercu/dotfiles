---
name: user-doc-audit
description: Audit and improve a user-facing entry doc (README, docs-site landing, man-page intro, getting-started guide) for factual accuracy and for three reader audiences — evaluator, newcomer, returner. Use when asked to "improve/proofread/audit the readme (or docs)", "is my readme any good", "make the docs clearer / more motivating", or to check docs for stale/inaccurate information.
---

# User-doc audit

Goal: entry doc where every claim true + genuinely useful to 3 readers. Audit
**entry** docs (README, docs landing, man intro, getting-started). **Reference**
docs (API site, full spec) = canonical homes you link TO, not the target.

## Two prime directives (hold every phase)
1. **Accuracy.** Worst defect = confident false statement. Verify every
   checkable claim vs source before trust — incl repo's own claims. No
   propagate unverified.
2. **One canonical home per fact.** Duplication = root of doc rot: copies
   drift, then one lies. Each fact lives ONE place; others link, not copy. Same
   fact in 2 places → don't sync — de-dup: pick home, others reference.

## Three audiences (always these; adapt to lib/app/CLI/service)
- **Evaluator** — adopt? Entry doc = pitch deck: show how beautifully it solves
  problems they have. (Don't force to one; differentiator count irrelevant.)
- **Newcomer** — ramp fast. Needs install, smallest working example, then
  progressive disclosure, mental model of core concept.
- **Returner** — refresh fast. Best served by a doc small + scannable enough to
  re-find in; reference near end. TOC is a last resort, not a goal.

## Phase 0 — sources of truth + audiences
Find target doc + authorities: code, public-API snapshot, tests, `--help`,
config defaults, exit codes, platforms/versions, canonical reference
(docs/spec/man). Note which audiences matter most here.

## Phase 1 — read whole + claim inventory
Read entire doc. List every checkable claim: flags, defaults, counts,
version/MSRV, platforms, behavior, ordering, "mirrors X", perf, "all Y in Z".

## Phase 2 — verify every claim (load-bearing, exhaustive)
Each claim → confirm vs source empirically (grep/read, run `--help`, the test
that enforces it). External claims → authoritative upstream, 2 sources when
possible. Flag every stale/wrong; false claim = defect, fix now. Exhaustive —
not just sections you touch.

Claim won't verify? May indict the *software*, not the doc — that's a software
defect, don't paper over it in prose. Flag + follow the thread (these cluster);
route fix to `harden`/`tdd`, then doc records reality. (maintenance-first: a
finding is a lead.)

## Phase 3 — audience audit
Check the doc serves each (these are goals, not layout):
- Evaluator: does it pitch — reader feels "this elegantly solves problems I
  have", fast and honestly (no overclaim)?
- Newcomer: can they install + reach a first success quickly, then go deeper?
  Is the core mental model conveyed?
- Returner: can they re-find / refresh quickly (small + scannable)?

## Phase 4 — restructure + rewrite
Structure is **contextual**: choose whatever best conveys THIS software's
message to the three audiences. No fixed template, no mandated sections — let
the content + readers' needs drive the shape.

Durable constraints (quality goals, not layout):
- Directive #2: trim reference that duplicates a canonical source + will drift
  (e.g. full API tables) → link canonical. Guard over-trim: keep sync-tested /
  operational / no-home-elsewhere tables.
- Cut maintainer cruft (test-sync notes, internal rationale) — doc is for users.
- Digestible size; prefer trimming over nav aids; TOC is a last resort.
- Frame standard behavior as standard, not "surprising"; no overclaim.

Techniques to reach for *only when they fit* (tools, not requirements):
mental-model diagram, smallest-working example before fuller ones, a
positioning line, a recipes/gotchas section for edge cases.

## Phase 5 — verify result (MANDATORY gate; skip a check only w/ stated reason)
- Anchors resolve (if any internal links/TOC exist) — each → real heading.
- Examples compile + use current API (doctests / scratch build).
- Sync-tested tables pass; re-grep stale refs (renamed/removed things).
- Cross-doc: no contradiction w/ coupled docs (API/spec/man). Fix whichever
  wrong; if from duplication, collapse to one canonical home (#2).

## Gate
Accuracy fixes + small clarity edits = apply direct (commit per slice).
HARD-STOP for user at:
- Structural rewrite → findings + plan first, edit on approval.
- Reversing an authority doc (spec/ADR/contract) → surface conflict, no silent
  override.
