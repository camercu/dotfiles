---
name: simplify
description: Review changed code for reuse, quality, and efficiency, then fix any issues found. Understands before touching, guards against over-simplification.
---

# Simplify

Review changed code for reuse, quality, efficiency; fix findings. Metric is comprehension speed, not line count: "Would a new team member understand this faster than the original?" For module-level structural work (seams, ports, depth) use `/improve-architecture` instead.

## Phase 0: Understand Before Touching (Chesterton's Fence)

Read `CONTEXT.md` / `CLAUDE.md` / project conventions if present, then study the diff. For each non-obvious changed piece, know its responsibility, callers/callees, edge cases, and why it might be written that way (perf? platform constraint? history?). Use `git blame` when something looks wrong but might be intentional. If intent unclear, ask the user before simplifying.

## Phase 1: Identify Changes

`git diff` (or `git diff HEAD` if staged changes exist). No git changes → review files the user mentioned or you edited this conversation.

## Phase 2: Three Review Agents in Parallel

Launch concurrently in a single message, each with the full diff:

1. **Reuse** — find existing utilities/helpers that replace newly written code (check utility dirs, shared modules, adjacent files); flag new functions duplicating existing ones and inline logic an existing utility covers.
2. **Quality** — redundant/derivable state; parameter sprawl instead of restructuring; copy-paste with slight variation; leaky abstractions; stringly-typed code where constants/enums/branded types exist; comments explaining WHAT or narrating the change (keep only non-obvious WHY).
3. **Efficiency** — redundant computation / repeated reads / duplicate calls / N+1; independent operations run sequentially; new blocking work on startup or hot paths; unconditional state updates in polling loops/handlers (add change-detection guard); TOCTOU existence pre-checks (operate directly, handle the error); unbounded structures / missing cleanup / listener leaks; reading or loading more than needed.

## Phase 3: Fix Issues

Wait for all three, aggregate, fix each directly. False positive or not worth it → note and skip; don't argue with the finding.

### Do NOT simplify when

- **Inlining a named helper** — the name is the value; inlining hurts the call site.
- **Merging unrelated logic** — one reason to change per function.
- **Removing load-bearing indirection** — testability/extensibility seams; check whether tests depend on it first.
- **Trading readability for line count** — a 5-line if/else beats a nested ternary.
- **Removing error handling** — that's behavior, not style.
- **Code you don't fully understand** — back to Phase 0.
- **Drive-by refactors outside the diff** — stay scoped unless asked.
- **500+ lines by hand** — use codemods/sed/AST transforms instead.

## Phase 4: Verify

- [ ] Existing tests pass unmodified (tests needing changes = behavior changed — revisit)
- [ ] Build, linter, formatter clean; no new warnings
- [ ] No dead code left (unused imports, unreachable branches)
- [ ] No error handling removed or weakened
- [ ] Each change incremental and reviewable; conventions followed
- [ ] "New team member" test passes

Any check fails → revert that simplification. Briefly summarize fixes (or confirm code already clean).
