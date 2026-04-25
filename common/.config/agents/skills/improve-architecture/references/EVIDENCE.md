# Evidence Gathering

Quantitative signals to ground architectural analysis. Collect before presenting candidates (Step 2). Not every signal available in every project — gather what's practical.

## Git hotspots

Files that change frequently signal complexity concentration:

```bash
git log --format=format: --name-only --since="6 months ago" | sort | uniq -c | sort -rn | head -20
```

## Co-change coupling

Files that appear in the same commits signal hidden coupling:

```bash
git log --format=format: --name-only --diff-filter=AMRC | awk 'NF{arr[NR]=$0} !NF{for(i in arr) for(j in arr) if(i<j) print arr[i], arr[j]; delete arr}'
```

Simpler heuristic: scan recent PRs for files that always move together.

## Fan-in / fan-out

Count imports per module:

- **High fan-in** = many dependents → risky to change, high-value deepening candidate
- **High fan-out** = many dependencies → fragile module, likely shallow

## Test coverage gaps

Modules with low coverage are high-risk deepening candidates — but also high-value if deepening makes them testable through a tighter interface.

## Churn x complexity

Files with both high churn AND high complexity = top priority. Use `wc -l` as rough complexity proxy if no tooling available. Cross-reference the hotspots command output with line counts on those files.

## Using evidence

- Rank candidates by evidence strength, not gut feel
- Multiple signals converging on same module = high confidence
- Single weak signal = mention but don't over-weight
- No evidence available = proceed with structural analysis, note the gap
