# Shore's Architectural & Infrastructure Patterns — Detailed Reference

These patterns govern how the deepened module is structured and how its infrastructure dependencies are wrapped and tested.

---

## A-Frame Architecture

**The structural backbone for modules with category 3–4 dependencies.**

**Problem:** Traditional layered architectures put infrastructure at the bottom, so logic depends on infrastructure. This makes logic untestable without real infrastructure.

**How it works:** Infrastructure and Logic are peers. Neither depends on the other. Both are coordinated by the Application layer above them. Data flows between them as Value Objects.

```
         Application Layer
        /                  \
Infrastructure Layer    Logic Layer
   (no dependency between them)
```

**Key constraint:** The Logic layer never calls Infrastructure directly. The Application layer coordinates: read from Infrastructure → process in Logic → write to Infrastructure (Logic Sandwich), or respond to events from either layer (Traffic Cop).

**Why it matters for deep modules:** You can test the Logic layer with pure inputs and outputs, and the Infrastructure layer with Narrow Integration Tests. The Application layer is thin enough to test with Nullables.

---

## Logic Sandwich

**The coordination pattern for sequential data processing.**

**How it works:**
1. Application reads data via Infrastructure layer
2. Application passes data to Logic layer for processing
3. Application writes results via Infrastructure layer

Repeat in a loop for stateful processing.

```typescript
// Application layer
async function processOrder(orderId: string) {
  const order = await db.fetchOrder(orderId);          // Infrastructure
  const result = orderLogic.calculateTotal(order);      // Logic
  await db.saveOrder({ ...order, total: result.total }); // Infrastructure
}
```

**When to use:** Straightforward data processing flows. If the interaction becomes complex (Logic needs to call Infrastructure in the middle, or Infrastructure pushes events), switch to Traffic Cop.

---

## Traffic Cop

**The coordination pattern for event-driven flows.**

**How it works:** Application uses an Observer/event pattern to listen for events from Infrastructure or Logic. For each event, it implements a Logic Sandwich.

```typescript
// Application layer
messageQueue.onMessage((msg) => {          // Infrastructure event
  const processed = logic.process(msg);   // Logic Sandwich start
  auditLog.write(processed);             // Logic Sandwich end
});
```

**When to use:** Event-driven applications, reactive systems, WebSocket handlers, message queue consumers. Anywhere Logic Sandwich would require Infrastructure to be called from the middle of Logic.

---

## Infrastructure Wrappers

**The fundamental isolation pattern for all external dependencies.**

**Problem:** Infrastructure code is complex, unreliable, and tightly coupled. Direct use of external APIs throughout a codebase creates widespread coupling to the third-party API shape.

**How it works:**
- One class per external system (one for the database, one for the email service, etc.)
- The wrapper's API matches application needs, not the external API
- All interaction with the external system goes through this class
- The wrapper is the only place that knows about the third-party library

```rust
// Bad: application code depends on reqwest directly
let resp = client.get("https://api.stripe.com/charges").send().await?;

// Good: wrapped behind an application-shaped interface
let charge = payment_gateway.charge(amount, card_token).await?;
```

**Design the API for the caller, not the dependency:**
- If you need 3 of Stripe's 40 API methods, expose 3 methods with application-domain names
- Expose only the fields your application uses, not the full response shape
- Handle error translation inside the wrapper

**Makes Nullables possible:** The wrapper is the seam where you introduce `createNull()`.

---

## Narrow Integration Tests

**How to test Infrastructure Wrappers against real external systems.**

**Problem:** Infrastructure Wrappers need real communication verification, but broad integration tests are slow and brittle.

**How it works:**
- Test the wrapper against an isolated, local version of the system (SQLite, LocalStack, local SMTP)
- Tests start and configure the local system themselves
- Use the same configuration as production (same driver, same query syntax)
- Keep tests focused: one wrapper, one behavior, one test

**What they don't test:** Application logic, coordination between layers, or end-to-end flows. Those are covered by tests using Nullables.

**For multiple similar systems:** Create a generic low-level wrapper tested with Narrow Integration Tests, then layer a higher-level wrapper on top that's made Nullable with Fake It Once You Make It.

---

## Paranoid Telemetry

**For production-grade Infrastructure Wrappers.**

**Problem:** External systems fail in unexpected ways. Silent failures are catastrophic.

**How it works:** In every Infrastructure Wrapper:
- Assume the external system will fail
- Handle every failure mode explicitly: timeouts, connection errors, malformed responses, hung requests, rate limits
- Log or emit metrics on every failure with enough context to diagnose in production
- Test each failure mode with a Narrow Integration Test or Behavior Simulation

**Test the failure paths:** Use Behavior Simulation or Configurable Responses to trigger each failure mode in tests and assert that the wrapper produces the correct log output (Output Tracking on the logger).

**Why:** The wrappers are the most critical failure points in the system. Bugs here are the hardest to diagnose in production.

---

## Easily-Visible Behavior

**For making Logic layer code testable.**

**Problem:** Logic can only be tested with state-based assertions if its results are observable.

**Three approaches (pick the simplest that fits):**

**1. Pure functions** — return values determined solely by input parameters. No side effects.
```rust
fn calculate_retry_delay(attempt: u32, base_ms: u64) -> Duration { ... }
```

**2. Immutable objects** — state established at construction, never modified. Operations return new instances.
```rust
let policy = RetryPolicy::new().with_max_attempts(5);
let policy2 = policy.with_wait(WaitFixed::new(Duration::from_secs(1)));
// policy unchanged
```

**3. Observable mutable objects** — expose state through getters or events. Only use when immutability is impractical.

**Red flag:** If a function explicitly depends on or changes dependency state more than one level deep, it's a sign of poor abstraction — the Logic layer is doing Infrastructure work.
