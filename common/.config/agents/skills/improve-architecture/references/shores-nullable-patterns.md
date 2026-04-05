# Shore's Nullability Patterns — Detailed Reference

These patterns let you test code that depends on external systems without real infrastructure and without locking in implementation details (the mock problem).

---

## Nullables

**The central pattern.** An Infrastructure Wrapper with a `createNull()` factory that disables external communication while preserving all normal behavior.

**How it works:**
```typescript
class EmailService {
  static create() { return new EmailService(new SmtpTransport()); }
  static createNull(options = {}) { return new EmailService(new NullTransport(options)); }
  // Normal methods work identically either way
}
```

**Key properties:**
- `createNull()` is production code, not test infrastructure
- The Nulled instance behaves identically except it doesn't talk to external systems
- Enables "dry run" modes and local development without real services
- Requires Zero-Impact Instantiation and Parameterless Instantiation as prerequisites

**What it replaces:** Mocks. Unlike mocks, Nullables don't couple to which methods were called or in what order.

---

## Embedded Stub

**For wrapping third-party libraries** directly (low-level Infrastructure Wrappers).

**How it works:** Write a hand-written stub that replaces the third-party library inside the wrapper. Test-drive it through your wrapper's interface to avoid over-building. The stub lives in the same file as the wrapper.

```typescript
// Production wrapper using real library
class DiceRoller {
  static create() { return new DiceRoller(new RealRandomLib()); }
  static createNull(options = {}) { return new DiceRoller(new NullRandomLib(options)); }
}

// Stub — in same file, implements only what DiceRoller uses
class NullRandomLib {
  constructor({ values = [3] } = {}) { this._values = [...values]; this._i = 0; }
  random() { return this._values[this._i++ % this._values.length]; }
}
```

**Critical:** The stub must mimic third-party behavior exactly, including edge cases. Test the stub itself against the third-party docs.

**Pitfall:** Don't stub your own code — only the third-party boundary.

---

## Thin Wrapper

**For statically-typed languages** where the third-party interface is bloated or unavailable.

**How it works:** Define a minimal interface with only the methods you use. Provide two implementations: one forwarding to the real library, one as the Embedded Stub.

```rust
trait RandomSource {
    fn next_f64(&mut self) -> f64;
}

struct RealRng(SmallRng);
impl RandomSource for RealRng { ... }

struct NullRng { values: Vec<f64>, idx: usize }
impl RandomSource for NullRng { ... }
```

**Why:** Avoids depending on the third-party's full interface in your stub, which would require implementing unused methods.

---

## Configurable Responses

**For scenarios where Nulled dependencies need to return different values** (non-determinism: time, UUIDs, random numbers, staged external states).

**How it works:** `createNull(options)` accepts optional configuration defining what the Nullable returns.

```typescript
// Options defined at the behavior level, not HTTP level
const mailer = EmailService.createNull({ bounced: true });
const clock = Clock.createNull({ now: new Date("2024-01-15") });
const rng = DiceRoller.createNull({ values: [1, 6, 3] }); // array cycles
```

**Rules:**
- Name options after observable behavior, not implementation (`bounced: true` not `statusCode: 550`)
- Scalar values repeat indefinitely; arrays cycle through values in sequence
- Use named/optional parameters so adding new options doesn't break existing tests

**For nested deps:** Decompose responses to the next Nullable level — don't duplicate stub logic.

---

## Output Tracking

**For asserting on writes and side effects** (emails sent, events published, database writes, metrics recorded) without real infrastructure.

**How it works:** Add `trackXxx()` methods to the wrapper that return a tracker object. The tracker listens to an internal event emitter that fires on every write — in both Nulled and production instances.

```typescript
class EmailService {
  trackSent() { return new OutputTracker(this._emitter, 'sent'); }

  async send(msg) {
    await this._transport.send(msg);
    this._emitter.emit('sent', msg); // fires in both real and Null instances
  }
}

// In test:
const mailer = EmailService.createNull();
const sent = mailer.trackSent();
await mailer.send({ to: "user@example.com", subject: "Welcome" });
assert.deepEqual(sent.data, [{ to: "user@example.com", subject: "Welcome" }]);
```

**Key insight:** Track behavior (what was written), not invocations (that a method was called). This survives refactoring.

**Unlike spies:** Output trackers record structured data about actions, not method calls. Tests stay coupled to behavior, not implementation.

---

## Behavior Simulation

**For external systems that push events** (WebSockets, message queues, IoT sensors, webhooks).

**How it works:** Add simulation methods to the wrapper that call the same internal handlers as real events do. This shares implementation between the real and simulated paths.

```typescript
class MessageQueue {
  // Called by real queue when a message arrives
  #handleMessage(msg) { this._emitter.emit('message', msg); }

  // Called by tests to simulate incoming messages
  simulateMessage(msg) { this.#handleMessage(msg); }

  // Real subscription path
  subscribe() { this._client.on('message', (m) => this.#handleMessage(m)); }
}
```

**Often paired with Output Tracking** — simulate input, track output.

**Critical:** The simulation method must share code with the real handler, not duplicate it. Otherwise the simulation won't catch bugs in the real path.

---

## Fake It Once You Make It

**For high-level Infrastructure Wrappers** and application-layer code that composes lower-level dependencies that already have Nullables.

**How it works:** Don't create new Embedded Stubs at the high level. Instead, `createNull()` instantiates Nulled versions of all dependencies and decomposes any high-level Configurable Responses into formats those lower-level Nullables understand.

```typescript
class OrderService {
  static createNull(options = {}) {
    const { paymentDeclined = false } = options;
    return new OrderService(
      PaymentGateway.createNull({ declined: paymentDeclined }),
      InventoryService.createNull(),
      EmailService.createNull()
    );
  }
}
```

**Why:** Avoids duplicating stub logic at multiple levels. The low-level Nullables already handle the real test boundaries; high-level Nullables just compose them.

**Decompose responses:** If `OrderService.createNull({ paymentDeclined: true })` configures the behavior, it decomposes that into `PaymentGateway.createNull({ declined: true })` — translating from application semantics to dependency semantics.
