---
name: comments
description: Audit, write, and improve code comments against John Ousterhout's "A Philosophy of Software Design" principles. Use when the user asks to review, clean up, improve, or write comments in source code. Triggers on: "review comments", "clean up comments", "improve docs", "comment audit", "are these comments good", "write better comments", "remove redundant comments".
---

# Comments Skill

Audit and improve source code comments using Ousterhout's principles from "A Philosophy of Software Design". See `references/principles.md` for the full framework.

## Workflow

1. **Read the file(s)** in full before evaluating anything
2. **Classify every comment** — is it load-bearing or noise?
3. **Fix in place** — edit files directly, don't just report
4. **Verify** — run `cargo check` (or equivalent) after changes
5. **Summarize** changes by file, explaining *why* each was kept, removed, or rewritten

## Quick Decision Rules

**Remove if** the comment:
- Restates the identifier name or type in prose (`/// Number of attempts` on field `attempts: u32`)
- Translates the next line into English (`// increment x` above `x += 1`)
- Is a section-divider banner naming what the next block does (`// --- Loop over items ---`)
- Duplicates information already in the struct/trait doc immediately above

**Rewrite if** the comment:
- Is vague ("// handle the case", "// process items")
- States the mechanism when it should state the contract
- Is an interface comment that leaks implementation detail
- Uses "blanket implementation" / "wrapper" / "helper" language when the user-visible contract is what matters

**Keep and strengthen if** the comment:
- Documents a non-obvious invariant (ordering, no-short-circuit, saturation behavior)
- Explains WHY a design decision was made (not what)
- Captures a constraint not visible in types (units, null semantics, boundary conditions)
- Is an interface comment describing the full contract (behavior, side effects, edge cases)

## Refactor Over Comment

If a comment is needed to explain *what* code does (not *why*), prefer to rename or restructure the code to be self-explanatory, then remove the comment. A well-named function beats a comment on a poorly-named one.

## Scope by Comment Type

| Type | Location | Should Contain |
|------|----------|----------------|
| Module `//!` | Top of file | Scope and strategy — what invariant this module/file establishes, not a list of its contents |
| Struct/trait `///` | Declaration | Contract: what it represents, invariants, constraints not in types |
| Method/fn `///` | Declaration | Interface contract: behavior, args, returns, side effects, edge cases — NOT implementation |
| Field `///` | Field | Purpose, constraints, units, valid range — NOT just the field name in prose |
| Inline `//` | Body | WHY this approach, non-obvious invariants, gotchas — NOT what the next line does |

## Common Patterns Found in Practice

- **Constructor docs**: `new()` rarely needs a doc — the struct doc already describes what it creates
- **Obvious return docs**: `/// Returns the foo` on `fn foo() -> Foo` adds nothing
- **Feature-gate docs**: `/// Enabled with the X feature.` is visible from `#[cfg(feature = "x")]`
- **Test module docs**: Replace bullet lists of test names with a sentence on what invariant is verified and why this approach (seeded PRNG, real timer, no-op executor, etc.)
- **Blanket impl docs**: Replace "Blanket implementation for Fn..." with the user-visible fact: "Any `Fn(...)` can be used directly without wrapping"

For the full principles and worked examples, see `references/principles.md`.
