# Shore's Foundational Patterns — Detailed Reference

Prerequisites for applying the Nullability patterns. These govern how modules are designed so they can be instantiated and used in tests without complex setup.

---

## Zero-Impact Instantiation

**Constructors do no significant work.**

**Problem:** Constructors that connect to databases, start servers, or perform expensive computation make tests slow, cause side effects, and produce unpredictable failures.

**How it works:**
- Constructor only assigns parameters and sets up in-memory state
- External system connections go in a separate `connect()`, `start()`, or `open()` method
- Expensive computation uses lazy initialization

```rust
// Bad: constructor does real work
impl EmailService {
    fn new(config: Config) -> Self {
        let conn = SmtpConnection::connect(&config.smtp_host); // blocks, can fail
        EmailService { conn }
    }
}

// Good: constructor is trivial
impl EmailService {
    fn new(config: Config) -> Self {
        EmailService { config, conn: None }
    }
    fn connect(&mut self) -> Result<()> {
        self.conn = Some(SmtpConnection::connect(&self.config.smtp_host)?);
        Ok(())
    }
}
```

**Why it matters for Nullables:** `createNull()` can instantiate the class without triggering real connections, because the constructor doesn't connect.

---

## Parameterless Instantiation

**All classes constructable without arguments; dependencies are wired internally.**

**Problem:** Multi-level dependency chains are hard to set up in tests. Dependency injection frameworks are "magic" that obscures wiring.

**How it works:**
- Factory methods (not constructors) handle the dependency wiring
- `create()` wires real dependencies; `createNull()` wires Nulled dependencies
- For Value Objects and domain classes, provide test-specific factories with optional parameters

```typescript
class OrderService {
  // Factory methods wire deps — no DI framework needed
  static create() {
    return new OrderService(
      PaymentGateway.create(),
      InventoryService.create(),
      EmailService.create()
    );
  }

  static createNull(options = {}) {
    return new OrderService(
      PaymentGateway.createNull(options.payment),
      InventoryService.createNull(),
      EmailService.createNull()
    );
  }

  // Private constructor: callers use factory methods
  constructor(private payment, private inventory, private email) {}
}

// In tests — no setup ceremony:
const service = OrderService.createNull();
```

**For Value Objects:** Provide a `forTest(overrides = {})` factory with all params optional and sensible defaults.

---

## Signature Shielding

**Helper functions wrap instantiation and method calls to localize signature changes.**

**Problem:** When a constructor or method signature changes (adding a parameter, reordering args), every test that calls it must be updated — busywork that scales badly.

**How it works:** Test helpers wrap construction and common method calls. When the signature changes, update the helper, not every test.

```typescript
// Helper in test file or shared test utilities
function makeOrder(overrides = {}) {
  return Order.forTest({
    id: "test-order-1",
    items: [makeItem()],
    ...overrides
  });
}

// Tests use the helper — insulated from signature changes
it("calculates total", () => {
  const order = makeOrder({ items: [makeItem({ price: 10 }), makeItem({ price: 20 })] });
  assert.equal(order.total(), 30);
});
```

**Also useful for:** Reducing repetition when the same setup appears across many tests, and for giving test scenarios meaningful names.

---

## Easily-Visible Behavior

**Logic results must be observable for state-based testing.**

See [shores-architectural-patterns.md](shores-architectural-patterns.md) for the full description. Summary of the three approaches:

1. **Pure functions** — return value determined solely by inputs. Easiest to test.
2. **Immutable objects** — operations return new instances; original unchanged.
3. **Observable mutable objects** — expose state through getters when immutability is impractical.

**The red flag:** If a function modifies or reads state more than one level deep through dependencies, the Logic layer is doing Infrastructure work. Pull it out into an Infrastructure Wrapper.

---

## Collaborator-Based Isolation

**Don't hardcode expected values when a dependency's value is what matters.**

**Problem:** If a test asserts `assert.equal(header, "123 Main St")` and the address formatting changes, the test breaks — even though the behavior being tested (address appears in header) is correct.

**How it works:** Use the dependency itself to define the expectation.

```typescript
// Bad: hardcoded expected value
assert.equal(invoice.header(), "123 Main St, Springfield, IL");

// Good: ask the address how it renders
assert.equal(invoice.header(), address.render());
```

**When to use:** When the dependency's specific behavior isn't central to the test, but you need to verify the code under test uses the dependency correctly. Provides coverage without brittleness.

**When NOT to use:** When the dependency's specific output IS what you're testing (then hardcode it).
