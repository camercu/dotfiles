---
name: simplify
description: Use when user asks to simplify changed code, review a diff for reuse, quality or efficiency, or says "simplify", "clean this up", "any duplication here". Not for module-level structural work (seams, ports, depth); use improve-architecture there.
---

# Simplify

## Overview

Review changed code for reuse, quality, efficiency; fix findings. Metric is comprehension speed, not line count: "Would a new team member understand this faster than the original?" For module-level structural work (seams, ports, depth) use `/improve-architecture` instead.

## Phase 0: Understand Before Touching (Chesterton's Fence)

Read `CONTEXT.md` / `CLAUDE.md` / project conventions if present, then study the diff. For each non-obvious changed piece, identify its responsibility, callers, and edge cases. Before removing a special case, compatibility behavior, or unfamiliar indirection, use `git blame` and `git log -p` to inspect the introducing and subsequent commits. Read a linked PR or ADR when available. Record the original constraint and evidence it still applies or has expired. If rationale is missing, record that and preserve the behavior unless current evidence establishes safe removal.

## Phase 1: Identify Changes

`git diff` (or `git diff HEAD` if staged changes exist). No git changes → review files the user mentioned or you edited this conversation.

## Phase 2: Review Through Three Lenses

If harden is coordinating, use its finding format and reuse any covered
lenses. Review the remaining questions in one pass. Use independent
reviewers where the risk tier or distinct expertise warrants it, with
separate findings paths and `~/.config/agents/record-as-you-go.md`.

1. **Reuse** — find existing utilities/helpers that replace newly written code (check utility dirs, shared modules, adjacent files); flag new functions duplicating existing ones and inline logic an existing utility covers.
2. **Quality** — redundant/derivable state; parameter sprawl instead of restructuring; copy-paste with slight variation; leaky abstractions; stringly-typed code where constants/enums/branded types exist; comments explaining WHAT or narrating the change (keep only non-obvious WHY).
3. **Efficiency** — redundant computation / repeated reads / duplicate calls / N+1; independent operations run sequentially; new blocking work on startup or hot paths; unconditional state updates in polling loops/handlers (add change-detection guard); TOCTOU existence pre-checks (operate directly, handle the error); unbounded structures / missing cleanup / listener leaks; reading or loading more than needed.

## Phase 3: Fix Issues

Aggregate findings across the lenses. Fix supported findings within scope
and record evidence for declines. In report-only mode record findings and
dispositions for the coordinator.

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
