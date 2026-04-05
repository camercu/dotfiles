# Comments Principles — A Philosophy of Software Design

John Ousterhout's framework from *A Philosophy of Software Design* (2nd ed.).

## Core Principle

**Comments capture what code cannot.** The purpose of a comment is to record information that was in the designer's mind but that cannot be represented in the code itself — design rationale, intent, constraints, trade-offs, and contracts.

> "If users must read the code of a method in order to use it, then there is no abstraction."

## The Two Failure Modes

### 1. Comments that repeat code

The most common problem. The comment says exactly what the code says, just in English. It adds zero information and creates maintenance burden.

```rust
// Bad: restates the name
/// Number of attempts executed.
attempts: u32,

// Bad: translates the expression
x = x.wrapping_add(1); // increment x with wrapping

// Bad: restates the return type
/// Returns the retry state.
fn state(&self) -> &RetryState { ... }
```

### 2. Comments that are vague

The comment exists but doesn't help. Often uses language like "handles", "processes", "manages", "deals with".

```rust
// Bad: vague
// Handle the error case.

// Good: specific
// Predicate rejection is checked before stop exhaustion, so a
// non-retryable error exits immediately rather than waiting for
// all attempts to expire.
```

## What to Comment

### Interface contracts (structs, traits, public functions)

Describe what a caller needs to know:
- **Behavior**: what the function/method does at a high level
- **Arguments**: units, valid ranges, null semantics, ownership transfer
- **Return value**: what it means, edge cases
- **Side effects**: mutations, I/O, panics
- **Invariants**: what must be true before/after

Do NOT describe how the implementation works.

```rust
// Good: contract, not mechanism
/// Clamps the sleep duration to the remaining timeout budget.
/// Returns zero if the budget is already exhausted, which causes
/// the execution loop to skip the sleep call entirely.
fn clamp_to_budget(delay: Duration, remaining: Duration) -> Duration

// Bad: mechanism, not contract
/// Computes min(delay, remaining) using saturating subtraction.
fn clamp_to_budget(delay: Duration, remaining: Duration) -> Duration
```

### Implementation comments (inside function bodies)

Explain *why*, not *what*:
- Why this algorithm or approach was chosen
- Non-obvious ordering constraints
- Why a special case exists
- A gotcha or known limitation

```rust
// Good: explains WHY
// Zero-duration sleep is skipped to avoid a blocking syscall
// on the final exhausted-budget iteration.
if delay > Duration::ZERO {
    sleep(delay);
}

// Bad: explains WHAT (obvious from the code)
// Check if delay is greater than zero
if delay > Duration::ZERO {
    sleep(delay);
}
```

### Module docs (`//!`)

Describe the *scope and strategy* of the module — what invariant it establishes and why it's organized this way. Not a table of contents.

```rust
// Good: strategy
//! Stop strategies determine when the retry loop halts.
//! All strategies are stateless and take `&self` — the execution
//! engine owns all mutable state, so strategies are freely cloneable.

// Bad: table of contents
//! This module contains:
//! - StopAfterAttempts
//! - StopAfterElapsed
//! - StopNever
```

### Data structure fields

Document purpose, units, constraints — not the name in prose.

```rust
// Good: adds information
/// Milliseconds elapsed since the first attempt. `None` when no
/// clock is available (no_std environments without a custom clock).
elapsed: Option<Duration>,

// Bad: restates the name
/// The elapsed duration.
elapsed: Option<Duration>,
```

## Comment-to-Code Ratio

More comments are not better. The goal is maximum information per token. A file with 10 precise, load-bearing comments is better than one with 50 redundant ones.

Ousterhout's heuristic: **if a comment is harder to read than the code it describes, delete it**.

## Abstraction Level

Comments should be at a *higher* abstraction level than the code. An implementation comment that restates the algorithm step-by-step is at the same level as the code — it will go stale and adds no value.

Good comments survive code refactors. If you rewrite the implementation but the contract stays the same, the comment should need no change.

## The "Obvious" Test

"Obvious" means obvious to a competent programmer reading this code for the first time — not to the author who wrote it. Authors systematically underestimate how much context they've accumulated. When in doubt, test by imagining a colleague who knows Rust but has never seen this codebase.

## Refactor Before Commenting

When a comment is needed to explain *what* code does, the code itself is unclear. Prefer:
1. Better naming (variables, functions, types)
2. Extracting a named function for a complex expression
3. Restructuring to make the intent obvious

Then the comment can be deleted or reduced to a one-liner explaining why.

## Types of Comments by Location

| Type | Purpose | Anti-pattern |
|------|---------|-------------|
| Module `//!` | Scope, strategy, key invariants | Listing contents |
| Struct/enum `///` | What it represents, invariants, constraints | Restating the name |
| Trait `///` | Contract, what implementors must guarantee | Describing typical implementation |
| Method/fn `///` | Interface contract | Describing implementation |
| Field `///` | Purpose, units, valid range | Restating the field name |
| Inline `//` | Why this approach, non-obvious invariant | Narrating the next line |

## Worked Examples from Rust Practice

### Section-divider banners — always remove

```rust
// Bad
// ---------------------------------------------------------------------------
// Composition types
// ---------------------------------------------------------------------------

// Also bad
// --- Sync tests ---
```

These are table-of-contents entries in the middle of a file. The code already shows what comes next; the banner adds no information.

### Constructor docs — usually remove

```rust
// Bad
/// Creates a new WaitFixed strategy.
pub fn new(duration: Duration) -> Self

// Remove it. "Creates a new X" is obvious from `new`. The struct doc
// describes what WaitFixed does; the constructor needs no separate doc
// unless it has non-obvious preconditions.
```

### Blanket impl docs — restate the user-facing contract

```rust
// Bad
/// Blanket implementation allowing any `Fn(Duration) -> Fut` where
/// Fut: Future<Output = ()> to serve as a Sleeper.

// Good
/// Any `Fn(Duration) -> Fut` can be passed directly as a sleeper,
/// without wrapping in a named type.
```

### Test module docs — describe strategy, not contents

```rust
// Bad
//! These tests verify:
//! - stop::attempts stops after N attempts
//! - stop::elapsed stops after the deadline

// Good
//! Stop strategy tests verify the `should_stop` contract for each
//! strategy using a deterministic test harness (no real timers).
//! The `StopAny`/`StopAll` tests explicitly verify the no-short-circuit
//! guarantee, which is non-obvious and affects stateful strategies.
```
