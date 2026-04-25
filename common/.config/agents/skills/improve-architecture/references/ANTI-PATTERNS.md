# Anti-Patterns

Common architectural smells mapped to the skill's vocabulary. Use during exploration (Step 1) to accelerate friction identification. Apply deletion test and skip guardrails before promoting any to a candidate.

| Anti-Pattern | Signal | Violated Concept | Response | Detection |
|---|---|---|---|---|
| **God Module** | Everything depends on it. High fan-in + fan-out, many concerns | Cohesion, Locality | Split along cohesion boundaries into deep modules. Each must pass deletion test independently | Fan-in > 2x median. File in > 30% of recent commits |
| **Pass-Through** | Adds no behavior — delegates with near-identical interface | Depth | Delete it. Let callers use underlying module directly. If exists "for testability," deepen underlying module instead | Deletion test: no complexity increase anywhere = pass-through |
| **Feature Envy** | Module A reaches into B's internals (nested property access, internal types) | Coupling, Abstraction boundary | Move envied logic into B's interface. Or extract shared concept into new deep module | Imports of internal types, deep property chains (`a.b.c.d.config`) |
| **Shotgun Surgery** | One change touches many files | Locality | Consolidate scattered logic into single deep module | Git co-change: files always in same commits. Single fix touching 5+ files |
| **Primitive Obsession** | Domain concepts as raw strings/ints. Validation scattered across callers | Depth, Abstraction boundary | Value object/type with validation at construction | Same regex/range check duplicated in N modules |
| **Speculative Generality** | Extension points, generics, plugin mechanisms with exactly one usage | Seam discipline | Inline the single implementation. Re-introduce seam only when second adapter is needed | Interface/trait with one impl. Generic always instantiated with same type |
| **Leaky Abstraction** | Callers handle implementation details (retries, SQL errors, format conversion) | Depth, Interface | Push details behind interface. Callers see domain errors, not transport errors | Callers catch `SQLException`/`HttpTimeoutError`. Callers configure connection pools |
| **Circular Dependency** | A → B → A (direct or indirect) | Coupling | Extract shared concept into new module, or invert with seam (A defines interface, B adapts) | Import cycle errors, or manual dependency trace |
| **Test-Induced Damage** | Extra interfaces/DI/indirection existing only for mocks | Depth | Deepen module so it's testable at boundary. Use in-process or local-substitutable strategies ([PATTERN-GUIDE.md](PATTERN-GUIDE.md) Cat 1–2) | Interfaces with one prod impl + one mock. Constructor mostly injected test deps |
