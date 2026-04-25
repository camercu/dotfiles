# Interface Design

When the user wants to explore alternative interfaces for a chosen deepening candidate, use this parallel sub-agent pattern. Based on "Design It Twice" (Ousterhout) — your first idea is unlikely to be the best.

Uses the vocabulary in [LANGUAGE.md](LANGUAGE.md) — **module**, **interface**, **seam**, **adapter**, **leverage**.

## Process

### 1. Frame the problem space

Before spawning sub-agents, write a user-facing explanation of the problem space for the chosen candidate:

- The constraints any new interface would need to satisfy
- The dependencies it would rely on, and which category they fall into (see [DEEPENING.md](DEEPENING.md))
- A rough illustrative code sketch to ground the constraints — not a proposal, just a way to make the constraints concrete

Show this to the user, then immediately proceed to Step 2. The user reads and thinks while the sub-agents work in parallel.

### 2. Spawn sub-agents

Spawn 3+ sub-agents in parallel using the Agent tool. Each must produce a **radically different** interface for the deepened module.

Prompt each sub-agent with a separate technical brief (file paths, coupling details, dependency category from [DEEPENING.md](DEEPENING.md), what sits behind the seam). The brief is independent of the user-facing problem-space explanation in Step 1. Give each agent a different design constraint:

- Agent 1: "Minimize the interface — aim for 1–3 entry points max. Maximise leverage per entry point."
- Agent 2: "Maximise flexibility — support many use cases and extension."
- Agent 3: "Optimise for the most common caller — make the default case trivial."
- Agent 4 (if applicable): "Design around ports & adapters for cross-seam dependencies."

Include both [LANGUAGE.md](LANGUAGE.md) vocabulary and CONTEXT.md vocabulary in the brief so each sub-agent names things consistently with the architecture language and the project's domain language.

Each sub-agent must use this structured output template:

```
## Design: [Agent's constraint label]

### Interface
- **Entry points**: list each method/function with signature
- **Types**: key types the caller interacts with
- **Invariants**: what the module guarantees (e.g., "always returns normalized data")
- **Error modes**: what can fail and how (domain exceptions, not implementation ones)
- **Ordering constraints**: any required call sequences

### Usage Example
[Concrete code showing the most common caller using this interface]

### Hidden Complexity
- What the implementation owns internally
- Which internal seams exist (if any) and why

### Dependency Strategy
- Dependency category (from DEEPENING.md): in-process / local-substitutable / remote-owned / true-external
- Adapters needed: list each adapter (production + test at minimum)
- Internal vs external seams

### Trade-offs
| Dimension   | Rating (H/M/L) | Explanation |
|-------------|-----------------|-------------|
| Leverage    |                 | Capability per unit of interface |
| Locality    |                 | How concentrated are future changes |
| Flexibility |                 | How well it handles edge cases / new use cases |
| Simplicity  |                 | How easy for a new developer to understand |
```

### 3. Present and compare

Present designs sequentially so the user can absorb each one, then compare them in prose. Contrast by **depth** (leverage at the interface), **locality** (where change concentrates), and **seam placement**.

After comparing, give your own recommendation: which design you think is strongest and why. If elements from different designs would combine well, propose a hybrid. Be opinionated — the user wants a strong read, not a menu.
