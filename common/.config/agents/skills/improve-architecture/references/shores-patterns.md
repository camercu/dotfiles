# James Shore's Testing Without Mocks — Pattern Overview

Quick reference for selecting patterns when deepening modules in categories 2–4. Read this file first; load detailed files only for patterns you intend to apply.

## Core Philosophy

Shore's pattern language enables fast, reliable, maintainable tests without mocks (which couple to implementation) or broad end-to-end tests (which are slow and brittle). It uses:

- **State-based testing**: verify observable output, not which methods were called
- **Sociable tests**: real dependencies execute; overlapping narrow tests provide coverage
- **Nullables**: production code with optional "no external communication" mode — not test-only doubles

---

## Pattern Quick Reference

### Foundational (read before applying any other patterns)

| Pattern | One-line description | Load details when... |
|---------|---------------------|----------------------|
| Zero-Impact Instantiation | Constructors do no significant work; connect/start methods handle setup | any dep class has a heavy constructor |
| Parameterless Instantiation | All classes constructable without arguments; sensible defaults wire deps | test setup is complicated |
| Signature Shielding | Helper functions wrap instantiation/calls to localize signature changes | many tests call the same constructor |
| Easily-Visible Behavior | Logic returns values (pure fn), uses immutable objects, or exposes observable state | logic is hard to assert on |

See [shores-foundational-patterns.md](shores-foundational-patterns.md) for details.

### Architectural (how to structure the deepened module)

| Pattern | One-line description | Load details when... |
|---------|---------------------|----------------------|
| A-Frame Architecture | Infrastructure and logic are peers; neither depends on the other | designing a new deep module with category 3–4 deps |
| Logic Sandwich | App reads infra → processes logic → writes infra | straightforward data-processing flow |
| Traffic Cop | App listens for events; responds with Logic Sandwiches | event-driven or reactive flow |
| Infrastructure Wrappers | One class per external system; API matches app needs, not external API | any category 2–4 dep |

See [shores-architectural-patterns.md](shores-architectural-patterns.md) for details.

### Nullability (how to make the deep module testable without real infrastructure)

| Pattern | One-line description | Use for dep category... |
|---------|---------------------|------------------------|
| Nullables | `createNull()` factory disables external communication; normal behavior preserved | 2, 3, 4 |
| Embedded Stub | Hand-written stub replaces third-party library inside the wrapper | 4 (external libs) |
| Thin Wrapper | Minimal custom interface over third-party API; two impls: real + stub | 4 (statically typed) |
| Configurable Responses | `createNull(options)` returns predetermined values for different test scenarios | 2, 3, 4 |
| Output Tracking | `trackXxx()` methods capture writes/events for assertion without real infra | 3, 4 (side effects) |
| Behavior Simulation | Methods simulate incoming external events; share code with real handlers | 4 (push-based deps) |
| Fake It Once You Make It | High-level Nullables delegate to Nullable dependencies | 3, 4 (layered deps) |

See [shores-nullable-patterns.md](shores-nullable-patterns.md) for details.

### Infrastructure testing

| Pattern | One-line description | Load details when... |
|---------|---------------------|----------------------|
| Narrow Integration Tests | Tests against real external system, isolated and local | you need to verify the Wrapper itself works |
| Paranoid Telemetry | Every failure mode logs/alerts; test all failure paths | category 4 external services |

See [shores-architectural-patterns.md](shores-architectural-patterns.md) for details.

---

## Pattern Selection by Dependency Category

### Category 2 — Local-substitutable

Goal: make the boundary between the module and its local stand-in clean and testable.

1. Wrap the dep in an **Infrastructure Wrapper** with an API that matches app needs
2. Make the wrapper **Nullable** with `createNull()`
3. Use **Configurable Responses** for non-deterministic behavior (time, randomness, UUIDs)
4. Write **Narrow Integration Tests** against the real local stand-in

### Category 3 — Remote but owned (Ports & Adapters)

Goal: define a port (interface) so the logic can be tested without network calls.

1. Apply **A-Frame Architecture**: logic and infrastructure are peers under the app layer
2. Wrap the remote dep in an **Infrastructure Wrapper** implementing the port
3. Make it **Nullable** with `createNull()`; use **Fake It Once You Make It** if it wraps lower-level Nullables
4. Use **Output Tracking** to assert on writes/events without real infrastructure
5. Test the real adapter with **Narrow Integration Tests**

### Category 4 — True external (Mock boundary)

Goal: isolate the third-party API behind a clean boundary testable without network calls.

1. Wrap the API in an **Infrastructure Wrapper**; use a **Thin Wrapper** if the third-party interface is bloated
2. Create an **Embedded Stub** inside the wrapper (test-drive it to avoid over-building)
3. Make it **Nullable** with `createNull(options)` using **Configurable Responses**
4. Use **Output Tracking** for writes and **Behavior Simulation** for push events
5. For higher-level code, use **Fake It Once You Make It** to delegate to the already-Nullable wrapper
