# Pass brief

Use for self-review or an independent reviewer. Combine applicable lenses in
one pass when they fit the same scope. For independence, provide the contract,
range and verification commands. Hold back earlier verdicts and fix rationale.

## Common

- Scope: absolute repository path, base..head, highest-risk behavior.
- Contract: governing docs and interface. Quote conflicts in findings.
- Checks: commands, required environment, actual exit statuses, and log paths.
- Review method: apply Review below. When `code-review` is installed, use it
  for ordinary code review and ensure the boundary and evidence instructions
  here are covered. Name the method and any delegated skills in the report.
- Findings: write to the assigned scratch path per
  `~/.config/agents/record-as-you-go.md`. Review agents leave tracked files and
  history untouched. Put proposed fixes and decision requests in findings.

## Finding format

Give each finding a stable ID and include the affected contract and code
location, expected versus actual behavior, a reproducible scenario or concrete
code evidence, proposed correction, and impact. Separate evidence from severity:

| Classification | Evidence |
|---|---|
| Verified defect | A reproducible failing scenario or executable check against the contract. |
| Supported risk | Evidence of a credible harmful path whose failure has not been established. State what remains unknown and why direct verification may be impractical or unsafe. |
| Hypothesis | A possibility without a demonstrated path. Name the experiment that would distinguish it from expected behavior. |

Record accepted, rejected or deferred disposition after triage and link the
test, commit, or rationale. A hypothesis alone is not an actionable defect.

## Exercise

Run `dogfood` against the affected interface and report by its friction format.
Link any reproduction and its setup to the finding ID.

## Review

1. Walk changed contracts and their callers. Check regressions, boundary
   assumptions, wiring coverage, error and retry paths, and security. Look for
   siblings of demonstrated defects. Inspect existing mutation evidence before
   running probes on uncovered behavior.
   For external contracts, persisted state, cleanup, dependencies, packaging,
   security, or concurrency, trace one or two consequential assumptions beyond
   the diff to their consumers. Probe them and record the assumptions cleared,
   findings, and any gaps. Use [Soundness](soundness.md) for unchecked invariants.
2. Question design where relevant: which branches, abstractions or types
   could disappear while preserving behavior? Surface larger changes as
   candidates with trade-offs and historical constraints.
3. For final-range review, verify affected fixes and surface unresolved risk.
   Report coverage and findings. The coordinator determines convergence from
   this review, consumer rechecks, and the final matrix.

## Convergence

Review the changed behavior or remaining gap on the final range. Record
significant findings still open and which slices or consumer scenarios were
rechecked. Cite prior independent coverage for unchanged behavior.
