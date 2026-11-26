# Test-health fixes

Read when fixing a `test-design-reviewer` finding.

Prefer the smallest correction that improves defect detection,
feedback speed, determinism, or maintenance cost.

## Slow and flaky tests

Target: whole suite ≤10s, zero flakes.

Treat slow and flaky tests as design findings. Correct the source of
latency or nondeterminism rather than accommodating it.

Apply `~/.config/agents/skills/test-design-reviewer/SKILL.md`
*Sleeps and flakes are design findings* for architectural remedies.

- **Settling sleep or timeout-based polling** → expose deterministic
  completion or state observation.
- **Uncontrolled time or randomness** → inject a controllable clock
  or RNG.
- **Logic entangled with infrastructure** → functional core,
  imperative shell; humble object; sans-IO; nullable infrastructure.
- **Shared mutable state** → explicit ownership or per-test isolation.
- **Concurrent nondeterminism** → deterministic synchronization
  or simulation.
- **Expensive setup** → lightweight, isolated fixtures.
- **Slow integration test** → move decisions into a fast, deterministic
  core; retain necessary integration contracts.

Longer sleeps, larger timeouts, retries, serial execution, and disabling
tests do not resolve the underlying defect.

Demonstrate that the correction removes the source of nondeterminism
or latency. Repeated passing runs alone do not establish that a
race is fixed. Measure runtime before and after performance corrections.

Where verification inherently requires expensive or real-infrastructure
execution, retain it in an explicit verification tier and justify its
cost.

## Other findings

- **Unnecessary test** → delete or consolidate after establishing
  that no unique contractual coverage is lost.
- **Avoidable invariant** → simplify production structure before
  adding tests that police it.
- **Coverage gap** → verify the missing behavior, not the uncovered line.
- **Weak assertion** → demonstrate the escaped defect with a targeted
  mutation or reproduction; show that the corrected test detects it.
- **Confounded fixture** → isolate the behavior under test and demonstrate
  that its incorrect implementation fails.
- **Recurring defect family** → prefer one structural invariant or
  systematic behavioral check over accumulating individual tests.
- **Quality bar that matters** → use an executable ratchet or CI gate.
  For source-text guards, apply `~/.config/agents/guard-ladders.md`
  *Test guards*.

Triage mutation survivors according to `test-design-reviewer`.
Equivalent, unreachable, and inconclusive mutants do not justify
adding tests merely to improve a mutation score.

## Implementation

Implement accepted findings through Harden step 3. Group corrections
with the same root cause into a coherent slice.

Record finding provenance in the resulting commit body using Git
trailers:

    Finding-Source: test-health
    Finding-Type: surviving-mutant

Finding types:

- surviving-mutant
- weak-assertion
- coverage-gap
- confounded-fixture
- redundancy
- flakiness
- isolation
- feedback-cost
- structural-simplification

Use the primary finding type. Repeat the trailer only when the
commit addresses materially different findings.

Done when the correction addresses the underlying cause, its
verification criteria are met, the applicable matrix is green,
and the commit records provenance.
