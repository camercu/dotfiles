---
name: improve-architecture
description: Explore a codebase to find opportunities for architectural improvement, focusing on making the codebase more testable by deepening shallow modules. Use when user wants to improve architecture, find refactoring opportunities, consolidate tightly-coupled modules, or make a codebase more AI-navigable. Outputs proposals directly in chat — does NOT create GitHub issues.
---

# Improve Codebase Architecture

Explore a codebase, surface architectural friction, and propose module-deepening refactors — presenting the proposal directly in chat for the user to act on.

A **deep module** (John Ousterhout) has a small interface hiding a large implementation. Deep modules are more testable, more AI-navigable, and let you test at the boundary instead of inside.

## Process

### 1. Explore the codebase

Use the Agent tool (subagent_type=Explore) to navigate organically. Note friction, not symptoms:

- Where does understanding one concept require bouncing between many small files?
- Where is the interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but real bugs hide in how they're called?
- Where do tightly-coupled modules create integration risk at their seams?
- Which parts are untested, or hard to test?

The friction you encounter IS the signal.

### 2. Present candidates

Present a numbered list of deepening opportunities. For each candidate:

- **Cluster**: Which modules/concepts are involved
- **Why they're coupled**: Shared types, call patterns, co-ownership of a concept
- **Dependency category**: See [references/dependency-categories.md](references/dependency-categories.md) for the four categories
- **Test impact**: What existing tests would be replaced by boundary tests

Do NOT propose interfaces yet. Ask: "Which of these would you like to explore?"

### 3. User picks a candidate

### 4. Frame the problem space

Write a user-facing explanation of the chosen candidate:

- The constraints any new interface must satisfy
- The dependencies it must rely on
- A rough illustrative code sketch grounding the constraints — this is NOT a proposal

For **categories 2–4**, also read [references/shores-patterns.md](references/shores-patterns.md) to identify which Shore patterns apply. Note them here — they will shape the sub-agent briefs.

Show this to the user, then immediately proceed to Step 5.

### 5. Design multiple interfaces

Spawn 3+ sub-agents in parallel using the Agent tool. Each produces a **radically different** interface.

Give each a technical brief (file paths, coupling details, dependency category, Shore patterns that apply). Assign distinct constraints:

- Agent 1: "Minimize the interface — aim for 1–3 entry points max"
- Agent 2: "Maximize flexibility — support many use cases and extension"
- Agent 3: "Optimize for the most common caller — make the default case trivial"
- Agent 4 (categories 3–4): "Design for Shore's A-Frame Architecture with Nullables for the boundary"

Each sub-agent outputs:

1. Interface signature (types, methods, params)
2. Usage example showing how callers use it
3. What complexity it hides internally
4. Dependency strategy — how deps are handled, including specific Shore patterns used
5. Trade-offs

Present designs sequentially, then compare in prose.

Give a recommendation: which design is strongest and why. If elements combine well, propose a hybrid. Be opinionated.

### 6. User picks an interface (or accepts recommendation)

### 7. Present the proposal in chat

Present the final proposal as a structured document directly in the conversation. Use the template in [references/dependency-categories.md](references/dependency-categories.md). Do NOT create a GitHub issue.
