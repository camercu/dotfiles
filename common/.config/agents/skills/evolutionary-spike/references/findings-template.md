# Findings-doc template

Copy to `docs/spikes/<topic>-findings.md`. LIVING record + resumable checkpoint —
update every phase transition, review, elimination, decision. Keep ephemeral
orchestration bits (in-flight agent IDs) OUT; put them in the run log or nowhere.

---

# Spike: <topic> — findings

## Question
<the design/feasibility question being resolved>

## Constraints (requirements, not solutions)
<the hard properties every spike must satisfy>

## Contract
<honesty mandate + comparability harness (the deterministic demo) + verify commands>

## Run state (checkpoint — resume from here)
- Phase: <frame | breadth | converge | refine | decide>
- Tier: <light | heavy>
- Pending spikes: <ids awaiting build/review>
- Live finalists: <ids + one-line each>
- Next action: <what to do on resume>

## Round log
- Round N: <spiked what, modes, convergence observations>

## Eliminated
For each cut — capture BEFORE deleting:
- <id> — ELIMINATED (dominated by <x>). Why lost: <…>. What didn't work: <…>.
  Carry forward: <salvageable tidbit / lead for a future spike>.

## Finalists
- <id> — <what it represents> — open axis: <the tradeoff it sits on>.

## Recommendation
<the winner + why> → see ADR <docs/adr/NNNN-…>.
