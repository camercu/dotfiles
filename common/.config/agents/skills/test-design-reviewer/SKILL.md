---
name: test-design-reviewer
description: Use when reviewing test suites for quality, behavioral coverage, defect detection, redundancy, slow or flaky tests, or weak assertions.
context: fork
agent: Explore
model: sonnet
---

# Test Design Reviewer

## Overview

Maintain a fast, reliable, deterministic test suite that detects defects,
survives behavior-preserving refactoring, and minimizes maintenance cost.

Review three independent dimensions:

- **Quality:** Are the tests well designed?
- **Completeness:** Are consequential behaviors exercised?
- **Efficacy:** Would the tests detect incorrect behavior?

Output actionable findings ranked by engineering impact. A healthy suite
with no significant findings is a successful review.

## Boundaries

Leave tracked files and repository history untouched. The caller implements
accepted fixes.

Follow `~/.config/agents/record-as-you-go.md`. Use the caller's findings path
or `.scratch/test-health/`. If the fork cannot write files, return findings
for the caller to persist.

Direct tool output to `.scratch/test-health/`. Tools that mutate source
in place run against a disposable copy: colocated jj can snapshot an
in-place mutant into repository history.

For infrastructure tests, judge coverage and necessity against
`~/.config/agents/skills/tdd/iac.md`.

## Process

### 1. Establish scope

Identify:

- Repository, commit range or paths, governing contracts, and risk.
- Test framework, runner, feature and platform configurations.
- Existing test, coverage, mutation, and timing evidence.
- Tests excluded by runner, privileges, feature flags, or environment.

Reuse evidence covering the same code, behavior, and configuration.
Investigate gaps and evidence invalidated by subsequent changes.

Prefer the project's verification commands.

Done when scope, applicable evidence, and verification gaps are recorded.

### 2. Sleeps and flakes are design findings

Fast, reliable, deterministic feedback is the purpose of a test suite.
Target: whole suite ≤10s, zero flakes.

Slow tests discourage frequent execution. Flaky tests destroy trust in
failures. Both are significant findings.

A test that needs a sleep, settling period, timeout-based polling, or
retry to observe a result exposes a design problem: the test cannot
deterministically control or observe the behavior.

Treat these as architectural findings. Trace latency and nondeterminism
to their source in production code, infrastructure, or the test harness.
Redesign for deterministic testability rather than accommodating a
design that produces slow or unreliable tests.

#### Architectural remedies

| Problem | Preferred remedy |
|---|---|
| Logic entangled with I/O | Functional core, imperative shell |
| Logic buried in UI, threads, or handlers | Humble object |
| Protocol logic coupled to transport | Sans-IO state machine |
| Uncontrolled external infrastructure | Nullable infrastructure |
| Implicit infrastructure dependencies | Ports and adapters; dependency injection |
| Wall-clock dependence | Injected or virtual clock |
| Uncontrolled randomness | Injected, seeded RNG |
| Waiting for work to finish | Explicit completion signal, future, channel, or event |
| Decisions coupled to execution | Plan-execute: return actions as data |
| Concurrent or distributed nondeterminism | Deterministic simulation and reproducible schedules |
| Shared mutable state | Explicit ownership or per-test isolation |
| Expensive repeated setup | Lightweight, isolated fixtures |
| Test adapter may diverge from reality | Shared adapter contract tests |

Introduce seams through ordinary constructor or parameter injection.
Keep domain logic independent of infrastructure. Prefer the smallest
design change that makes behavior fast and deterministic.

See `~/.config/agents/skills/tdd/testing-without-mocks.md` for nullable
infrastructure and functional-core patterns.

#### Review rules

- Flag arbitrary sleeps used to wait for observable behavior, regardless
  of duration or apparent reliability.
- Flag timeout-based polling used instead of deterministic synchronization.
- Treat intermittent failures as defects, even when rare. Subsequent
  passing runs do not clear a flaky-test finding.
- Measure suite runtime and identify dominant costs when execution
  exceeds the feedback budget.
- Investigate whether slow integration tests expose logic that belongs
  in a functional core.
- Look for architectural changes that eliminate entire classes of slow
  or flaky tests.
- Recommend a root-cause correction, naming the seam and where it
  enters the production design.

Longer sleeps, larger timeouts, retry-until-green wrappers, serial
execution, and disabling tests are not substitutes for root-cause
correction.

A bounded timeout that detects deadlock or nontermination is appropriate
as a failure guard, not as synchronization.

Tests of genuine timing contracts and real infrastructure boundaries may
require real time or I/O. Keep them narrow, deterministic where possible,
and justify their cost. Where verification is inherently expensive,
separate it into an explicit verification tier while preserving its
required coverage. Report its runtime separately; moving a test does
not make it faster or resolve flakiness.

For each finding, record the observed problem, its cause or the
experiment needed to establish it, the proposed architectural correction,
and how to verify the improvement.

Done when slow and nondeterministic tests have been investigated and
root-cause corrections recommended. Unresolved significant findings
remain open.

### 3. Review test design

Read tests before implementation. Identify what each test promises
to verify, then inspect production code and its contracts.

Apply Dave Farley's eight properties:

| Property | Review question |
|---|---|
| Understandable | Can the reader identify the behavior and expected outcome without reconstructing the implementation? |
| Maintainable | Does the test survive behavior-preserving refactoring? |
| Repeatable | Does the same input reliably produce the same result? |
| Atomic | Can the test run independently, in any order? |
| Necessary | Does it provide unique behavioral evidence? |
| Granular | Does failure identify a specific broken behavior? |
| Fast | Does it support frequent execution? |
| First | Is there evidence that tests drove the design? |

Judge each property against the test's purpose. Real I/O is appropriate
for a necessary adapter contract test. Exact ordering is appropriate
when ordering is contractual. Multiple assertions about one outcome
are appropriate.

Test-first development cannot reliably be inferred from final source.
Use development history or recorded red-green evidence when available.

#### Necessity and the deletion test

What defect would deleting this test allow to escape?

- No unique value → remove or consolidate.
- Same behavior at several tiers → retain the cheapest sufficient
  coverage and necessary boundary contracts.
- Test mirrors implementation → assert observable behavior.
- Test polices an avoidable invariant → make the invalid state
  unrepresentable or remove the underlying duplication.
- Test scans source or configuration → apply
  `~/.config/agents/guard-ladders.md` *Test guards*.

Prefer eliminating production complexity over strengthening tests
that compensate for it.

Done when consequential design weaknesses and unnecessary tests have
been identified, with evidence of their engineering cost.

### 4. Audit assertion strength

Always perform this step.

For consequential behaviors, ask:

**What plausible incorrect implementation would still pass these tests?**

Inspect for:

| Weakness | Diagnostic |
|---|---|
| Tautology | Outcome predetermined by setup, independent of production behavior. |
| Mock-only | Asserts a configured response or interaction without verifying production behavior. |
| Framework test | Verifies the language or framework rather than the product. |
| Existence-only | Checks existence or completion without verifying required properties. |
| Shape without content | Checks length, type, or status without verifying required contents. |
| Wrong-reason success | A negative test passes because the operation failed for an unrelated reason. |
| Interaction instead of outcome | Checks internal calls rather than contractual effects. |
| Self-referential oracle | Expected result reproduces production logic and can share its defect. |
| Loose assertion | Accepts incorrect values, effects, or states outside the contract. |
| Over-specification | Asserts incidental implementation details, making correct refactors fail. |
| Confounded fixture | Changes several variables so the test passes for reasons unrelated to its stated purpose. |
| Missing negative space | Verifies the desired effect but misses prohibited effects, cleanup, or preserved state. |

These are diagnostic signals, not automatic findings. A length assertion
is sufficient when length is the contract.

For each actionable weakness:

1. Name the incorrect behavior that escapes detection.
2. Identify the test that should detect it and why it remains green.
3. Propose the smallest independent assertion or fixture that distinguishes
   correct from incorrect behavior.
4. Demonstrate the escape with a targeted mutation or reproduction when
   practical.

Prefer exact assertions where the contract is exact, independently
derived expected values, and fixtures that isolate the behavior
under test.

Done when consequential assertions have been examined and suspected
weaknesses have evidence or a named verification gap.

### 5. Review behavioral coverage

Trace affected contracts to executable tests:

- Public interfaces and acceptance criteria.
- Boundary conditions and state transitions.
- Invalid inputs, rejection, and error propagation.
- Cleanup, rollback, cancellation, and recovery.
- Security, permissions, and resource ownership.
- Integration wiring and platform or feature-specific behavior.

Prioritize behaviors by failure impact. Investigate neighboring
behaviors when a demonstrated gap suggests a wider defect pattern.

Distinguish:

- **Unexercised:** No test reaches the behavior.
- **Unverified:** A test reaches it without asserting its outcome.
- **Outside runner:** Another test verifies it, but the selected runner
  or configuration does not execute that test.

#### Programmatic coverage

Reuse applicable coverage evidence or run the project's coverage tool
when available within the review budget.

Confirm tool availability. For runner failures caused by process-global
state (signals, descriptors, environment), try a per-test-isolating
runner, e.g. `cargo llvm-cov nextest`.

Use uncovered regions to locate consequential behavioral gaps.
Coverage percentages are supporting evidence, not the objective.

Record tool, scope, configurations, relevant gaps, and limitations.
Unavailable or impractical tooling → manual review; state what
remains unverified.

Done when consequential contracts have been traced to tests or
recorded as gaps.

### 6. Verify efficacy

Use mutation testing to challenge assertions on consequential behavior.

Reuse applicable TDD mutation evidence. Focus additional mutations on:

- Suspected weak assertions and confounded fixtures.
- Boundary comparisons and Boolean conditions.
- Error handling and failure propagation.
- Permission checks and prohibited effects.
- State transitions, rollback, and resource cleanup.
- Covered code whose behavior is not clearly asserted.

Prefer the project's mutation runner. Confirm availability and use a
bounded scope and execution budget, such as changed files or
`cargo mutants --in-diff <diff>`.

Where automated tooling is unavailable or unsuitable, use targeted
manual mutations in a disposable copy. Establish a passing baseline,
apply the mutation, and run the relevant tests.

A killed mutant demonstrates detection of that particular change.
A surviving mutant is a candidate gap, not automatically a finding.

#### Triage mutation results

| Classification | Disposition |
|---|---|
| Real gap | Reachable incorrect behavior survives. Report the missing behavioral evidence and smallest effective correction. |
| Equivalent | Mutation preserves contractual behavior. Clear with reasoning. |
| Unreachable | Construction or invariants prevent the mutated path. Consider deleting dead complexity. |
| Outside runner | Another test tier detects it. Verify that tier actually runs where required. |
| Behavioral timeout | Mutation demonstrably causes nontermination or violates a timing contract. Record as detected. |
| Inconclusive | Build failure, environmental failure, insufficient budget, or unexplained timeout. Record separately. |

Record each surviving mutant's location, mutation, affected contract,
tests that remained green, and disposition.

Investigate clusters for shared causes. Prefer one behavioral invariant
or systematic fixture that detects a family of defects over accumulating
individual tests.

If mutation testing is unavailable or impractical, state that efficacy
was assessed statically. Distinguish demonstrated escapes from suspected
ones.

Done when mutation results are triaged and significant efficacy gaps
have actionable findings.

## Findings

Follow `~/.config/agents/record-as-you-go.md`.

Rank findings by defect impact, likelihood of escape, feedback cost,
and maintenance burden.

Slow and flaky tests are significant findings. Prioritize architectural
corrections that eliminate recurring latency or nondeterminism over
isolated test repairs.

Each finding records:

- Stable ID, classification, and impact.
- Affected contract and `file:line`.
- Expected versus actual behavior or test weakness.
- Concrete escaped defect, false failure, or engineering cost.
- Evidence and reproduction, including mutation when applicable.
- Root cause, where established.
- Smallest effective correction and verification criteria.
- Provenance: `test-health` and finding type.

Classify evidence separately from impact:

- **Verified defect:** Executable evidence demonstrates the weakness.
- **Supported risk:** Concrete evidence identifies a credible failure
  or cost; state what remains unverified.
- **Hypothesis:** Insufficient evidence; name the experiment needed.

A hypothesis alone does not justify a fix.

Group findings with a common cause. Cosmetic findings do not justify
test rewrites.

Record cleared hazards and declined candidates with their reasoning
so subsequent reviews need not rediscover them.

## Report

Return:

1. **Verdict:** Whether significant findings remain. Summarize quality,
   completeness, and efficacy separately.
2. **Findings:** Ranked by impact, using the format above.
3. **Verification:** Commands, configurations, results, reused evidence,
   timing measurements, coverage, mutation dispositions, and limitations
   where applicable.
4. **Cleared candidates:** Material suspected weaknesses cleared during
   investigation, with reasons.

Order proposed corrections by leverage. Include deletion, consolidation,
and architectural simplification where warranted.

When no significant findings remain, say so. Additional findings
are not required to justify the review.

## Optional Farley Index

Calculate only when explicitly requested or when the caller requests
a quantitative baseline or retrospective comparison.

Score each property from 0–10 with concrete evidence:

- 9–10: exemplary
- 7–8: strong
- 5–6: mixed
- 3–4: weak
- 0–2: seriously deficient

| Property | Weight |
|---|---:|
| Understandable (U) | 1.50 |
| Maintainable (M) | 1.50 |
| Repeatable (R) | 1.25 |
| Atomic (A) | 1.00 |
| Necessary (N) | 1.00 |
| Granular (G) | 1.00 |
| Fast (F) | 0.75 |
| First (T) | 1.00 |

Weighted index:

    (1.5U + 1.5M + 1.25R + A + N + G + 0.75F + T) / 9

Report per-property evidence, scores, and the weighted result.
Mark unsupported properties unknown. If any property is unknown,
report the breakdown without a composite index.

Comparisons require comparable scope, configurations, and assessment
criteria.

The index measures design quality, not behavioral completeness or
efficacy. Significant individual findings take precedence over an
excellent aggregate score.

## Self-check

Before returning:

1. Every significant finding identifies a concrete engineering consequence
   and supporting evidence.
2. Settling sleeps, flaky tests, and consequential feedback bottlenecks
   have been investigated for architectural root causes.
3. Behavioral coverage and assertion strength were examined separately.
4. Mutation survivors were triaged before being called gaps.
5. Existing applicable evidence was reused.
6. Recommendations consider deleting complexity before adding tests.
7. Verification limitations are explicit.
8. Tracked files and repository history remain unchanged.

Done when the findings are recorded and the caller can implement
accepted corrections without repeating the investigation.

## Attribution

- Dave Farley, [Properties of Good Tests](https://www.linkedin.com/pulse/tdd-properties-good-tests-dave-farley-iexge/).
- Andrea LaForgia, [farley_score_plugin](https://github.com/mse-online/farley_score_plugin):
  scoring rubric and tautology-theatre methodology.
- James Shore, [Testing Without Mocks](https://www.jamesshore.com/v2/projects/nullables/testing-without-mocks):
  nullable infrastructure and testable architecture.
