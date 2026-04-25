# Refactoring Smells

Below is a concise mapping of major code smells from Martin Fowler’s _Refactoring_ catalog to their typical refactorings.

---

## Bloaters

- **Long Function** (function too long, hard to understand) → **Extract Function** (break out helper functions)
- **Large Class/Struct** (class/struct does too much) → **Extract Class / Struct** (split responsibilities)
- **Primitive Obsession** (overuse of primitive types instead of domain types) → **Replace Data Value with Domain Type** (encapsulate primitives in domain types)
- **Long Parameter List** (too many parameters) → **Introduce Parameter Object / Builder Pattern** (group related data or set gradually using builder pattern)
- **Data Clumps** (same data grouped repeatedly) → **Extract Class/Struct** (encapsulate recurring data together)

---

## Object-Orientation Abusers

- **Switch Statements** (type-based conditionals scattered across multiple locations) → **Replace Conditional with Polymorphism** (use subclasses/dispatch). Note: `match`/`switch` in a single location is often the right tool — the smell is scattered duplication of the same type-based branching, not pattern matching itself.
- **Temporary Field** (fields only used in certain cases) → **Extract Class/Struct** (isolate conditional state)
- **Refused Bequest** (subclass doesn't use inherited behavior) → **Replace Inheritance with Delegation** (favor composition)
- **Alternative Interfaces** (similar behavior, different APIs) → **Rename Method / Move Method** (unify interfaces, define common interface)

---

## Change Preventers

- **Divergent Change** (one class/module changed for many reasons) → **Extract Class/Module/Struct** (separate responsibilities)
- **Shotgun Surgery** (one change requires many small edits) → **Move Method / Move Field** (centralize related logic)
- **Parallel Inheritance Hierarchies** (changes mirrored across hierarchies) → **Move Method / Collapse Hierarchy** (reduce duplication)

---

## Dispensables

- **Lazy Class/Struct** (class/struct adds little value) → **Inline Class/Struct** (remove unnecessary abstraction)
- **Speculative Generality** (unused abstraction for future flexibility) → **Collapse Hierarchy / Remove Dead Code**
- **Data Class/Struct** (only getters/setters, no behavior) → **Encapsulate Field / Move Method** (add behavior to data). Note: in Rust, plain data structs are idiomatic — the smell is when external code repeatedly manipulates the struct's fields with the same logic instead of the struct owning that logic.
- **Duplicate Code** (same logic repeated) → **Extract Method / Pull Up Method** (reuse shared logic)
- **Comments** (excessive comments compensating for unclear code) → **Rename Method / Extract Method** (make code self-explanatory)

---

## Couplers

- **Feature Envy** (method uses another object’s data more than its own) → **Move Method** (place behavior with data)
- **Inappropriate Intimacy** (classes overly coupled) → **Move Method / Move Field** (reduce dependency)
- **Message Chains** (long chains of calls like a.b().c().d()) → **Hide Delegate** (encapsulate traversal)
- **Middle Man** (class/struct only delegates calls) → **Remove Middle Man** (call target directly)

---

## Other / Additional Smells

- **Incomplete Library Class/Struct** (library lacks needed behavior) → **Introduce Foreign Method / Local Extension**
- **Data Class/Struct / Record Abuse** (data structures manipulated externally) → **Encapsulate Record / Add Behavior**
- **Refactoring Loops / Overengineering** (excess abstraction cycles) → **Simplify / Inline Abstractions**

For code-level cleanup beyond TDD refactoring, run `/simplify`.
