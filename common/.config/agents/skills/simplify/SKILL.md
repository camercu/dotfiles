---
name: simplify
description: Review changed code for reuse, quality, and efficiency, then fix any issues found. Understands before touching, guards against over-simplification.
---

# Simplify

Review changed code for reuse, quality, and efficiency. Fix issues found. Goal is not fewer lines — it's code easier to read, understand, modify, and debug.

**Test:** "Would a new team member understand this faster than the original?"

For module-level structural changes (seams, ports, depth), use `/improve-architecture` instead.

## Context Loading

Phase 0 loads `CONTEXT.md` / `CLAUDE.md` / project conventions. Everything else comes from the diff. No other pre-loading needed.

## Phase 0: Understand Before Touching (Chesterton's Fence)

Before changing or removing anything, understand why it exists. If you see code that looks unnecessary, don't remove it until you know why it was written.

1. Read `CONTEXT.md` / `CLAUDE.md` / project conventions if present
2. Study the diff — what changed, what's the intent?
3. For each non-obvious piece of changed code, answer:
   - What is this code's responsibility?
   - What calls it? What does it call?
   - What are the edge cases and error paths?
   - Why might it have been written this way? (Performance? Platform constraint? Historical reason?)
4. Check `git blame` on surrounding code for context when something looks wrong but might be intentional
5. **If unsure about intent, ask the user** before simplifying

## Phase 1: Identify Changes

Run `git diff` (or `git diff HEAD` if there are staged changes) to see what changed. If there are no git changes, review the most recently modified files that the user mentioned or that you edited earlier in this conversation.

## Phase 2: Launch Three Review Agents in Parallel

Use the Agent tool to launch all three agents concurrently in a single message. Pass each agent the full diff so it has the complete context.

### Agent 1: Code Reuse Review

For each change:

1. **Search for existing utilities and helpers** that could replace newly written code. Look for similar patterns elsewhere in the codebase — common locations are utility directories, shared modules, and files adjacent to the changed ones.
2. **Flag any new function that duplicates existing functionality.** Suggest the existing function to use instead.
3. **Flag any inline logic that could use an existing utility** — hand-rolled string manipulation, manual path handling, custom environment checks, ad-hoc type guards, and similar patterns are common candidates.

### Agent 2: Code Quality Review

Review the same changes for hacky patterns:

1. **Redundant state**: state that duplicates existing state, cached values that could be derived, observers/effects that could be direct calls
2. **Parameter sprawl**: adding new parameters to a function instead of generalizing or restructuring existing ones
3. **Copy-paste with slight variation**: near-duplicate code blocks that should be unified with a shared abstraction
4. **Leaky abstractions**: exposing internal details that should be encapsulated, or breaking existing abstraction boundaries
5. **Stringly-typed code**: using raw strings where constants, enums (string unions), or branded types already exist in the codebase
6. **Unnecessary comments**: comments explaining WHAT the code does (well-named identifiers already do that), narrating the change, or referencing the task/caller — delete; keep only non-obvious WHY (hidden constraints, subtle invariants, workarounds)

### Agent 3: Efficiency Review

Review the same changes for efficiency:

1. **Unnecessary work**: redundant computations, repeated file reads, duplicate network/API calls, N+1 patterns
2. **Missed concurrency**: independent operations run sequentially when they could run in parallel
3. **Hot-path bloat**: new blocking work added to startup or per-request/per-render hot paths
4. **Recurring no-op updates**: state/store updates inside polling loops, intervals, or event handlers that fire unconditionally — add a change-detection guard so downstream consumers aren't notified when nothing changed
5. **Unnecessary existence checks**: pre-checking file/resource existence before operating (TOCTOU anti-pattern) — operate directly and handle the error
6. **Memory**: unbounded data structures, missing cleanup, event listener leaks
7. **Overly broad operations**: reading entire files when only a portion is needed, loading all items when filtering for one

## Phase 3: Fix Issues

Wait for all three agents to complete. Aggregate findings and fix each issue directly. If a finding is a false positive or not worth addressing, note it and move on — do not argue with the finding, just skip it.

### Do NOT simplify when

These are over-simplification traps. Check before each fix:

- **Inlining a named helper** — if the helper gives a concept a name, keep it. Inlining makes the call site harder to read even if the function is short.
- **Merging unrelated logic** — two simple functions merged into one complex function is not simpler. Functions should have one reason to change.
- **Removing abstraction that exists for testability or extensibility** — some indirection is load-bearing. Check if tests depend on the seam before removing it.
- **Optimizing for line count** — a 5-line `if/else` is simpler than a 1-line nested ternary. Comprehension speed is the metric, not line count.
- **Removing error handling for "cleanliness"** — error handling is behavior. Removing it changes what the code does, not how it looks.
- **Simplifying code you don't fully understand** — go back to Phase 0.
- **Drive-by refactors of unrelated code** — stay scoped to what changed unless explicitly asked to broaden.
- **Touching 500+ lines by hand** — if a refactoring would touch more than 500 lines, invest in automation (codemods, sed scripts, AST transforms) rather than manual edits. Manual changes at that scale are error-prone and exhausting to review.

### Common simplification patterns

#### Python

```python
# SIMPLIFY: Nested conditionals → guard clauses
# Before
def process(data):
    if data is not None:
        if data.is_valid():
            if data.has_permission():
                return do_work(data)
            else:
                raise PermissionError("No permission")
        else:
            raise ValueError("Invalid data")
    else:
        raise TypeError("Data is None")

# After
def process(data):
    if data is None:
        raise TypeError("Data is None")
    if not data.is_valid():
        raise ValueError("Invalid data")
    if not data.has_permission():
        raise PermissionError("No permission")
    return do_work(data)

# SIMPLIFY: Verbose dict building → comprehension
# Before
result = {}
for item in items:
    result[item.id] = item.name
# After
result = {item.id: item.name for item in items}

# SIMPLIFY: Redundant boolean return
# Before
def is_valid(input: str) -> bool:
    if len(input) > 0 and len(input) < 100:
        return True
    return False
# After
def is_valid(input: str) -> bool:
    return 0 < len(input) < 100
```

#### Rust

```rust
// SIMPLIFY: Match with single pattern → if let
// Before
match config.get("key") {
    Some(val) => process(val),
    None => {}
}
// After
if let Some(val) = config.get("key") {
    process(val);
}

// SIMPLIFY: Manual Option mapping → map/and_then
// Before
let result = match maybe_value {
    Some(v) => Some(transform(v)),
    None => None,
};
// After
let result = maybe_value.map(transform);

// SIMPLIFY: Redundant clone → borrow
// Before
fn process(items: &[String]) {
    for item in items {
        let owned = item.clone();
        println!("{owned}");
    }
}
// After
fn process(items: &[String]) {
    for item in items {
        println!("{item}");
    }
}

// SIMPLIFY: Nested Result handling → ? operator
// Before
fn read_config(path: &Path) -> Result<Config, Error> {
    let content = match fs::read_to_string(path) {
        Ok(c) => c,
        Err(e) => return Err(e.into()),
    };
    let config = match toml::from_str(&content) {
        Ok(c) => c,
        Err(e) => return Err(e.into()),
    };
    Ok(config)
}
// After
fn read_config(path: &Path) -> Result<Config, Error> {
    let content = fs::read_to_string(path)?;
    let config = toml::from_str(&content)?;
    Ok(config)
}
```

## Phase 4: Verify

After all fixes applied, run through this checklist:

- [ ] All existing tests pass without modification (if tests needed changes, you likely changed behavior — revisit)
- [ ] Build succeeds with no new warnings
- [ ] Linter/formatter passes
- [ ] Each simplification is a reviewable, incremental change
- [ ] Simplified code follows project conventions
- [ ] No error handling was removed or weakened
- [ ] No dead code was left behind (unused imports, unreachable branches)
- [ ] The "new team member" test: simplified version is genuinely easier to understand

**If any check fails, revert that simplification.** Not every simplification attempt succeeds.

Briefly summarize what was fixed (or confirm code was already clean).
