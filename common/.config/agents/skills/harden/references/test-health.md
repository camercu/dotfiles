# Test-health fixes

Read when fixing a `test-design-reviewer` finding. Each fix = its own slice
(step 3).

- **Flaky or slow test** → fix the source. Sync on the event the test waits
  for; a race in a test usually = real ordering bug in code.
- **Shared mutable global state** → per-test isolation.
- **Real I/O or clock** → injected or nullable infrastructure (functional core,
  imperative shell). Keep at most one narrow real-infra contract test per
  boundary.
- **Coverage gap** → trace to acceptance criteria; close the missing
  *behaviour*, not the uncovered line.
- **Weak assertions** → mutation testing over the range (`cargo mutants
  --in-diff <diff>` or the stack's tool); each survivor = finding.
- **Quality bar that matters** (coverage, lint, perf budget) → lock with a
  ratchet or CI gate that runs code. Guard that scans source or config text →
  read `~/.config/agents/guard-ladders.md` *Test guards* first.
