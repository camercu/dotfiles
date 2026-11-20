# Review and delivery evidence

Use transcript timestamps, review findings and dispositions, harden ledgers,
and Git. One JSON Lines row per accepted change, keyed by project directory
name under `--repos` and the full final commit SHA on local HEAD's first-parent
history. Link the source for each recorded measure in `evidence`. Keep the
working file under the retrospective state directory.

```json
{"project":"demo","commit":"<full SHA>","tier":"medium","started_at":"2026-11-01T12:00:00Z","accepted_at":"2026-11-01T13:00:00Z","review_rounds":2,"review_seconds":420,"accepted":1,"rejected":0,"deferred":0,"human_corrections":1,"regressions":0,"defect_classes":["package-consumer"],"evidence":{"delivery":"session.jsonl:12,80","review":".scratch/harden/LEDGER.md","regressions":"<follow-up window searched>"}}
```

- Required: `project`, `commit`, `accepted_at`, and `evidence`. Give acceptance
  its observed timestamp. Time-to-acceptance starts at the first authorized
  work and measures wall-clock time, including waiting. Date the outcome by
  acceptance in UTC. Tier is low, medium, high, or unknown.
- Count completed review rounds, elapsed review time when available, unique
  findings by disposition, distinct human corrections, and confirmed
  post-acceptance regressions. Tag verified defect classes consistently.
  Use the same follow-up duration for regression counts in both cohorts.
- Omit unknown fields. Zero and an empty class list mean that evidence
  established none. Git counts history independently. An outcome whose SHA
  is absent is counted as unresolved. A commit subject or prompt alone
  cannot establish review yield, corrections, or regressions.
- Git probes read local history only. Missing objects or a stalled Git
  command leave the affected measurement unknown.

Capture a pre-change snapshot and an equal-length post-change snapshot.
Compare within project and risk tier, with observed counts beside totals.
Use accepted findings per observed round or review hour only over changes
with both inputs. Inspect repeated reviews with low yield and the linked
findings before proposing fewer passes. Prioritize recurring classes for
executable checks. Small samples, uneven evidence, or a different mix of
projects leave workflow effects uncertain.
