# Testing Without Mocks

Below is a summary of every pattern in James Shore's Testing Without Mocks: A Pattern Language.

## Foundational Patterns

### 1) Narrow Tests

**Intent:** Keep most tests fast, readable, and resilient by testing small slices of behavior rather than the whole system. ([James Shore][1])
**Use when:** You're tempted to write end-to-end tests for everything; tests are slow/brittle. ([James Shore][1])
**How:** Assert one behavior/function at a time; unit tests are a common form. Use different strategies depending on what you're testing: logic patterns for pure computation, Nullables for code with infrastructure deps, and Narrow Integration Tests for infrastructure. ([James Shore][1])
**Pitfalls:** Over-narrowing into "tests that mirror implementation" rather than intent (see Collaborator-Based Isolation).

### 2) State-Based Tests

**Intent:** Avoid interaction-based tests that "lock in" dependency usage; instead assert only outputs/state. ([James Shore][1])
**Use when:** You're using mocks/spies to verify calls, arguments, and ordering, and refactors keep breaking tests. ([James Shore][1])
**How:** Drive code by inputs and assert returned values or externally visible state changes, with no assertions about how collaborators were invoked. ([James Shore][1])
**Pitfalls:** If behavior isn't visible (no return values/getters/events), fix design using Easily-Visible Behavior. ([James Shore][1])

### 3) Overlapping Sociable Tests

**Intent:** Test larger slices of the dependency graph _without mocks_, accepting that tests will execute real collaborator code, and let test coverage "overlap" across layers. ([James Shore][1])
**Use when:** You want confidence the system is wired correctly (composition, real interactions) while still avoiding slow end-to-end testing. ([James Shore][1])
**How:** Construct real objects for the unit under test and most dependencies; isolate only true infrastructure boundaries via Nullables/Infrastructure Wrappers. ([James Shore][1])
**Pitfalls:** Can cause "multiple failures" when a deep dependency bug breaks many tests; mitigate with Collaborator-Based Isolation + keeping tests focused. ([James Shore][1])

### 4) Smoke Tests

**Intent:** A small number of broad "does it basically run?" checks to catch catastrophic wiring/configuration issues. ([James Shore][1])
**Use when:** You need minimal end-to-end confidence without relying on a large brittle E2E suite. ([James Shore][1])
**How:** Write a few high-level tests that exercise the main vertical path(s), often with Nullables to avoid real infrastructure. ([James Shore][1])
**Pitfalls:** Don't let smoke tests become your main test portfolio; keep them few and stable. ([James Shore][1])

### 5) Zero-Impact Instantiation

**Intent:** Object construction should not cause real side effects (threads, sockets, file I/O, network). ([James Shore][1])
**Use when:** Merely "newing up" or instantiating a class triggers infrastructure work, making tests flaky/slow. ([James Shore][1])
**How:** Move side effects to explicit `start()/connect()/initialize()` methods; constructors only store dependencies and set in-memory state. ([James Shore][1])
**Pitfalls:** Hidden background activity started in constructors is especially test-hostile.

### 6) Parameterless Instantiation

**Intent:** Production code should be easy to instantiate correctly, while tests can still inject dependencies. ([James Shore][1])
**Use when:** Constructors require many dependencies and production setup is repetitive/error-prone. ([James Shore][1])
**How:** Provide a parameterless factory like `create()` that wires real dependencies; tests call constructors/factories that accept injected deps (often via Signature Shielding to keep setup readable). ([James Shore][1])
**Pitfalls:** Avoid hiding meaningful configuration; keep "default wiring" in the factory, not scattered.

### 7) Signature Shielding

**Intent:** Keep tests readable by hiding irrelevant constructor/setup parameters behind helpers with optional/named args and multi-return values. ([James Shore][1])
**Use when:** Tests need only 1–2 fields configured but constructors/helpers require many parameters. ([James Shore][1])
**How:** Create test helper functions that:

- accept named/optional params (or an Options object),
- supply sensible defaults for irrelevant fields, and
- return multiple values (e.g., `{sut, deps, outputs}`) so tests can assert outputs and also access constructed collaborators if needed. ([James Shore][1])
  **Pitfalls:** Don't turn the helper into a second implementation; keep it "wiring + defaults."

---

## Architectural Patterns

### 8) A-Frame Architecture

**Intent:** Make testing easier by preventing logic from directly depending on infrastructure. ([James Shore][1])
**Use when:** Layering pushes infrastructure to the bottom and everything indirectly depends on it, making tests expensive. ([James Shore][1])
**How:** Structure **Application/UI** on top, with **Logic** and **Infrastructure** as peers beneath it, with no dependencies between them; pass data via value objects. Coordinate at the Application layer using Logic Sandwich or Traffic Cop; test the Application layer using Nullables. ([James Shore][1])
**Pitfalls:** Optional, not mandatory; apply where it reduces coupling and test pain. ([James Shore][1])

### 9) Logic Sandwich

**Intent:** Let Application code bridge infrastructure and logic without them coupling to each other. ([James Shore][1])
**Use when:** You have A-Frame (or similar) separation and need a standard flow. ([James Shore][1])
**How:** In Application: **read** from Infrastructure → **process** in Logic → **write** via Infrastructure; repeat as needed. Test layers independently. ([James Shore][1])
**Pitfalls:** If the app is event-driven, a sandwich alone may not fit; use Traffic Cop. ([James Shore][1])

### 10) Traffic Cop

**Intent:** Coordinate event-driven systems while still keeping infrastructure and logic decoupled. ([James Shore][1])
**Use when:** Infrastructure or logic emits events (UI events, sockets, file system watchers, etc.). ([James Shore][1])
**How:** Application layer subscribes (Observer pattern) to events from infrastructure/logic; for each event, run a "mini" logic sandwich (read/compute/write). ([James Shore][1])
**Pitfalls:** Don't let event handling logic creep into infrastructure; keep orchestration in Application.

### 11) Grow Evolutionary Seeds

**Intent:** Build a system "outside-in" starting with an end-to-end behavior, but in a way that stays testable and grows into good architecture. ([James Shore][1])
**Use when:** Starting a new codebase and want early end-to-end value without committing to heavy infrastructure/UI early. ([James Shore][1])
**How:** Test-drive a trivial Application-layer class that returns results to tests (not UI), hard coding one infra-provided value initially, then refactor concepts into Logic and Infrastructure over time. ([James Shore][1])
**Pitfalls:** If the seed becomes a "god object," refactor earlier (split responsibilities as soon as it feels messy). ([James Shore][1])

---

## Logic Patterns

### 12) Easily-Visible Behavior

**Intent:** Make logic testable via state-based assertions by ensuring computation results are observable. ([James Shore][1])
**Use when:** Logic has hidden effects or no way to observe results cleanly. ([James Shore][1])
**How:** Prefer pure functions; for OO, prefer immutability; for mutable objects provide getters or events so state changes are observable. ([James Shore][1])
**Pitfalls:** Avoid "dig through internals" patterns (exposing deep structure just for tests); expose behavior-level results.

### 13) Testable Libraries

**Intent:** Reduce brittleness and improve testability by wrapping third-party code you don't control. ([James Shore][1])
**Use when:** A third-party library is hard to test against, has poor observability, or risks breaking changes/abandonment. ([James Shore][1])
**How:** Create a wrapper whose API matches _your app's needs_, not the library's. Add methods to provide visible behavior (getters/events), and keep the rest of the codebase depending only on your wrapper. ([James Shore][1])
**Pitfalls:** If the library touches external systems/state, treat it as infrastructure instead (Infrastructure Wrapper). ([James Shore][1])

### 14) Collaborator-Based Isolation

**Intent:** Keep tests narrow by isolating irrelevant collaborator behavior without using mock-style interaction assertions. ([James Shore][1])
**Use when:** Overlapping sociable tests make changes expensive because deep formatting/behavior changes cascade into many unrelated tests. ([James Shore][1])
**How:** Write narrow tests that focus on a specific case and treat collaborator results as "given," while expecting collaborators to have their own narrow tests. The goal is to ignore irrelevant collaborator details. ([James Shore][1])
**Pitfalls:** It tightens coupling to structure more than purely sociable tests, so use sparingly. ([James Shore][1])

---

## Infrastructure Patterns

### 15) Infrastructure Wrappers

**Intent:** Make infrastructure code understandable and testable by isolating it behind purpose-built adapters. ([James Shore][1])
**Use when:** Code touches external systems/state (network, DB, file system, env vars, time, etc.). ([James Shore][1])
**How:** Create **one wrapper per external system** with a clean domain-facing API. Test wrappers with Narrow Integration Tests + Paranoic Telemetry; make them testable via Nullability Patterns. ([James Shore][1])
**Pitfalls:** Over-general wrappers become leaky abstractions; the wrapper's API should match what your application needs. ([James Shore][1])

### 16) Narrow Integration Tests

**Intent:** Verify your infrastructure communication against real systems to catch subtle incompatibilities. ([James Shore][1])
**Use when:** Writing or changing infrastructure wrappers or embedded stubs; especially for edge cases like errors/async. ([James Shore][1])
**How:** Test real external communication (real files, DB, network). Keep tests narrow (one behavior/edge-case at a time) and aligned with production config. ([James Shore][1])
**Pitfalls:** Don't rely on broad integration tests for everything; keep them focused and few.

### 17) Paranoic Telemetry

**Intent:** Detect production failures early by adding diagnostic hooks to infrastructure code. ([James Shore][1])
**Use when:** Infrastructure failures can be subtle or intermittent and hard to debug post-fact. ([James Shore][1])
**How:** Add robust, testable logging/metrics/tracing around external calls and responses, including error paths; ensure it helps confirm assumptions your stubs/tests rely on. ([James Shore][1])
**Pitfalls:** Telemetry should be actionable; avoid noisy logs without context.

---

## Nullability Patterns

### 18) Nullables

**Intent:** Make code with infrastructure dependencies testable without mocks by providing "real-but-disabled" versions of dependencies. ([James Shore][1])
**Use when:** A dependency talks to external systems/state and you want sociable, state-based tests. ([James Shore][1])
**How:** Provide `create()` (real) and `createNull()` (nulled) factories. Nulled instances return safe defaults and perform no external I/O, but still execute your production logic paths where practical. They're also usable in production for "dry run" or cache warming. ([James Shore][1])
**Pitfalls:** Nullables are production-grade code and must be tested; don't treat them as "just test helpers." ([James Shore][1])

### 19) Embedded Stub

**Intent:** For low-level infrastructure wrappers, disable external access by stubbing the third-party boundary (not your own code). ([James Shore][1])
**Use when:** You need a nulled infrastructure wrapper and want to avoid scattering `if (nulled)` checks. ([James Shore][1])
**How:** Create a minimal stub of the third-party API inside the production file; test-drive it through your wrapper's public API; ensure behavior matches real code using Narrow Integration Tests focused on edge cases (errors, async). ([James Shore][1])
**Pitfalls:** Overbuilding the stub; or stubbing _your_ code instead of the external boundary, which reduces realism. ([James Shore][1])

### 20) Thin Wrapper

**Intent:** In languages needing interfaces (or when third-party APIs are too large), define your own small interface and provide real + stub implementations. ([James Shore][1])
**Use when:** You can't conveniently implement an embedded stub against the third-party type, or the interface is too broad. ([James Shore][1])
**How:** Create a custom interface matching the third-party signatures you actually use; implement a real adapter that forwards calls and a stub implementation used by `createNull()`. Wrap third-party return types too if needed. ([James Shore][1])
**Pitfalls:** Diverging from the real signature can cause production/stub mismatch; keep it exact for used methods. ([James Shore][1])

### 21) Configurable Responses

**Intent:** For state-based tests, allow nulled dependencies to return test-controlled values without manipulating real external state. ([James Shore][1])
**Use when:** Code under test reads from infrastructure (HTTP responses, clock time, DB reads, etc.). ([James Shore][1])
**How:** Let `createNull()` accept optional/named config that defines responses in terms of **externally visible behavior** (domain-level data), not implementation details (e.g., "emailVerified" vs "HTTP 200 with JSON"). Support sequences (list of responses that exhaust) and constants (repeat forever). Decompose high-level config into lower-level stub behavior inside the embedded stub if needed. ([James Shore][1])
**Pitfalls:** Configuring at the wrong abstraction level leads to brittle tests. ([James Shore][1])

### 22) Output Tracking

**Intent:** Verify writes to infrastructure via state-based assertions by tracking "otherwise invisible" outputs. ([James Shore][1])
**Use when:** Code writes to logs, stdout, queues, databases, network sends, etc. ([James Shore][1])
**How:** Add production-grade `trackXxx()` methods to dependencies (nulled or not) that record outputs as **domain-level events/objects**, not raw call logs. A common approach is emitting an event and having an `OutputTracker` collect emitted data. ([James Shore][1])
**Pitfalls:** Don't build "spies" that record function calls; track semantic actions so refactors don't break tests. ([James Shore][1])

### 23) Behavior Simulation

**Intent:** Test event-driven systems by simulating external events at the boundary, sharing code with real handlers. ([James Shore][1])
**Use when:** External systems push events (websockets, message buses, file watchers). ([James Shore][1])
**How:** Add simulation methods (e.g., `simulateConnection`, `simulateMessage`) on the dependency that call the same internal handlers used by real event callbacks. Combine with Output Tracking to assert results. ([James Shore][1])
**Pitfalls:** Duplicating logic between "real handler" and "simulate" paths; keep shared internal handlers. ([James Shore][1])

### 24) Fake It Once You Make It

**Intent:** For non-infrastructure code, create a Nullable by delegating to real dependencies (already nullable) rather than stubbing deep behavior up front. ([James Shore][1])
**Use when:** You're making higher-level code Nullable and its dependencies can be made Nullable. ([James Shore][1])
**How:** Implement `createNull()` by composing nulled dependencies and otherwise using real production logic; add Configurable Responses / Output Tracking / Behavior Simulation only where interaction with the outside world makes it necessary. ([James Shore][1])
**Pitfalls:** Don't over-stub high-level code; only introduce test-control mechanisms when needed by tests.

---

## Legacy Code Patterns

### 25) Descend the Ladder

**Intent:** Convert large dependency trees incrementally without boiling the ocean. ([James Shore][1])
**Use when:** The unit you want to convert has many transitive dependencies. ([James Shore][1])
**How:** When converting a module/class, convert it and its **direct dependencies**, but not deeper; gradually work downward through the dependency tree later. Classify converted units into categories (e.g., low-level infra wrappers vs everything else) and apply the appropriate nullability approach per category. ([James Shore][1])
**Pitfalls:** Requires temporary solutions (Throwaway Stubs) that you later remove; track and retire them.

### 26) Climb the Ladder

**Intent:** Convert small dependency trees faster without waste. ([James Shore][1])
**Use when:** The code's dependency tree is small enough that methodical "descending" is unnecessary. ([James Shore][1])
**How:** Prefer quicker conversion that avoids creating throwaway stubs; move upward after making key dependencies nullable and tests state-based. ([James Shore][1])
**Pitfalls:** For larger trees, you'll likely need Descend the Ladder to keep work bounded. ([James Shore][1])

### 27) Replace Mocks with Nullables

**Intent:** Systematically rewrite existing mock/spy-based tests into state-based tests using Nullables. ([James Shore][1])
**Use when:** Existing tests assert calls/ordering/arguments on doubles and block refactoring. ([James Shore][1])
**How:**

- Replace "configured return values" on mocks with Configurable Responses. ([James Shore][1])
- Replace "emit events" setups with Behavior Simulation. ([James Shore][1])
- Replace "assert called like X" with Output Tracking (often last, after configuration-only doubles). ([James Shore][1])
  **Pitfalls:** Converting call-assertion tests too early can be hard unless output tracking is already in place.

### 28) Throwaway Stub

**Intent:** Temporarily break a dependency chain so you can convert a unit without converting the entire subtree immediately. ([James Shore][1])
**Use when:** A direct dependency mixes logic+infrastructure and isn't yet nullable, but you want to convert the parent now (common in Descend the Ladder). ([James Shore][1])
**How:** Create a minimal stub used only to make the dependency "nullable enough" for the moment; later replace it with a proper nullable built via Fake It Once You Make It once the dependency is converted. ([James Shore][1])
**Pitfalls:** Don't let throwaway stubs become permanent; plan and execute their removal.

---

## Practical rules of thumb (compressed)

- Default to **Narrow + State-Based** tests. ([James Shore][1])
- Treat anything touching external state as **Infrastructure Wrapper + Narrow Integration Tests**, then make it **Nullable** via **Embedded Stub/Thin Wrapper**. ([James Shore][1])
- For higher layers, make code nullable by composition (**Fake It Once You Make It**), then add **Configurable Responses / Output Tracking / Behavior Simulation** only where needed. ([James Shore][1])
- Use **A-Frame + Sandwich/Traffic Cop** when you want architecture-level decoupling between logic and infrastructure. ([James Shore][1])

[1]: https://www.jamesshore.com/v2/projects/nullables/testing-without-mocks "James Shore: Testing Without Mocks: A Pattern Language"
