# Interface Design for Testability

## 1. Functional core, imperative shell

Push decisions into pure functions. Push I/O to the edges.

```python
# Testable: pure function, no deps
def calculate_discount(cart: Cart, rules: list[Rule]) -> Discount:
    applicable = [r for r in rules if r.matches(cart)]
    return max(applicable, key=lambda r: r.value, default=Discount.none())

# Hard to test: mixes logic and I/O
def apply_discount(cart_id: str) -> None:
    cart = db.get_cart(cart_id)
    rules = db.get_rules()
    # ... logic buried in I/O ...
    db.update_cart(cart_id, new_total)
```

```rust
// Testable: pure function
pub fn calculate_discount(cart: &Cart, rules: &[Rule]) -> Discount {
    rules.iter()
        .filter(|r| r.matches(cart))
        .max_by_key(|r| r.value)
        .map(|r| r.to_discount())
        .unwrap_or(Discount::none())
}
```

## 2. Return results, don't produce side effects

In the functional core, functions must be **pure** — no side effects of any kind. No mutation, no I/O, no database calls, no printing, no network requests. Take values in, return values out. Exceptions for error signaling are fine (control flow, not side effects).

Side effects belong in the imperative shell only.

```python
# Pure: returns result, no side effects
def validate_order(order: Order) -> list[ValidationError]:
    errors = []
    if not order.items:
        errors.append(ValidationError("empty_cart"))
    return errors

# Impure: mutates input, writes to DB, prints — belongs in shell, not core
def validate_order(order: Order) -> None:
    if not order.items:
        order.status = "invalid"  # mutation
        db.save(order)            # I/O
        print("Invalid order")    # I/O
```

```rust
// Testable: returns Result, no mutation
pub fn validate_order(order: &Order) -> Result<ValidatedOrder, Vec<ValidationError>> {
    let mut errors = vec![];
    if order.items.is_empty() {
        errors.push(ValidationError::EmptyCart);
    }
    if errors.is_empty() { Ok(ValidatedOrder::from(order)) }
    else { Err(errors) }
}
```

## 3. Small surface area

Fewer methods = fewer tests needed. Fewer params = simpler test setup.

Ask:
- Can I reduce the number of methods?
- Can I simplify the parameters?
- Can I hide more complexity inside? (deep module)

## 4. Make infrastructure replaceable for tests

```python
# Testable: inject dependency
class OrderService:
    def __init__(self, payment: PaymentClient):
        self._payment = payment

# Also testable: nullable infrastructure (no DI needed)
class OrderService:
    def __init__(self, payment: PaymentClient | None = None):
        self._payment = payment or PaymentClient(os.environ["STRIPE_KEY"])

# Test with nullable
def test_order():
    client = PaymentClient.create_null()
    svc = OrderService(payment=client)
```

```rust
// Testable: generic over trait
pub struct OrderService<P: PaymentPort> {
    payment: P,
}

// Also testable: nullable (no generics needed)
pub struct OrderService {
    payment: PaymentClient,
}

impl OrderService {
    pub fn new(payment: PaymentClient) -> Self { Self { payment } }
}

#[test]
fn test_order() {
    let client = PaymentClient::create_null(vec![/*...*/]);
    let svc = OrderService::new(client);
}
```

## 5. Verify through the interface

```python
# BAD: bypasses interface
def test_create_user():
    create_user(name="Alice")
    row = db.execute("SELECT * FROM users WHERE name = ?", ("Alice",))
    assert row is not None

# GOOD: through the interface
def test_create_user():
    user = create_user(name="Alice")
    retrieved = get_user(user.id)
    assert retrieved.name == "Alice"
```

If there's no way to verify through the interface, the interface is incomplete — add a query method or use output tracking.
