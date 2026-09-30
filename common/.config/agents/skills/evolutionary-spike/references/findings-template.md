# Findings-doc template

Copy everything below the line to `<topic>-findings.md`. Living record and
resume checkpoint: update at every phase transition, review, elimination
and decision. It holds durable state only; in-flight agent IDs stay in the conversation.

---

# Spike: <topic> — findings

## Question
<the design or feasibility question>

## Constraints (requirements, not solutions)
<hard properties every spike must meet, each tagged with the question it serves>

## Owed to production spec
<scope cut from the spike, owed to the production spec>

## Mechanisms
<known ways to build it, one directed spike each; user-approved>

## Contract
<comparability harness (the deterministic demo) + verify commands>

## Run state (resume from here)
- Phase: <frame | breadth | converge | refine | decide>
- Tier: <light | heavy>
- Confidence: <normal | lower: self-reviewed (Light)>
- Pending spikes: <ids awaiting build or review>
- Next action: <what to do on resume>

## Round log
- Round N: <what was spiked, modes, convergence seen>

## Eliminated
Write each entry before deleting the spike's files:
- <id> — eliminated (lost to <x>). Why lost: <…>. What didn't work: <…>.
  Carry forward: <salvageable idea or lead>.

## Finalists
- <id> — <what it represents> — open axis: <the trade-off it sits on>.

## Verdict
<winner + why, or don't-build + why> → ADR `docs/adr/NNNN-<topic>.md`.
