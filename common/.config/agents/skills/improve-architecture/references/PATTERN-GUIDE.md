# Testing Strategy Guide

Guide choices based on dependency category at the module's seam (see [DEEPENING.md](DEEPENING.md)). Prefer the simplest technique that produces maintainable, fast tests. **Avoid mocks unless truly necessary** — prefer fakes, state-based assertions, and the techniques below.

---

## Category 1: In-process dependencies

Pure computation, in-memory state, no I/O.

**Strategy**: Deepen the module, test at its public interface.

### Python

```python
# Before: shallow — caller orchestrates validation + calculation
def process_payment(order: Order) -> Receipt:
    validate = OrderValidator(order)
    if not validate.is_complete():
        raise InvalidOrderError()
    total = Calculator(order.items).total()
    if order.currency != "USD":
        total = total * CurrencyConverter(order.currency, "USD").rate()
    if order.discount:
        total = total * (1 - order.discount)
    return Receipt(total=total, items=order.items, status="paid")

# After: deep module hides validation, calculation, conversion
class PaymentProcessor:
    def process(self, order: Order) -> Receipt:
        self._validate(order)
        total = self._calculate_total(order)
        return Receipt(total=total, items=order.items, status="paid")

    def _validate(self, order: Order) -> None: ...
    def _calculate_total(self, order: Order) -> Decimal: ...

# Test at the interface
def test_process_payment_with_discount():
    order = Order(items=[Item("widget", 100)], discount=0.1, currency="USD")
    receipt = PaymentProcessor().process(order)
    assert receipt.total == Decimal("90.00")
```

### Rust

```rust
// Before: shallow — caller orchestrates
pub fn validate_order(order: &Order) -> Result<(), OrderError> { ... }
pub fn calculate_total(items: &[Item]) -> Decimal { ... }
pub fn apply_discount(total: Decimal, discount: f64) -> Decimal { ... }

// After: deep module
pub struct PaymentProcessor;

impl PaymentProcessor {
    pub fn process(&self, order: &Order) -> Result<Receipt, PaymentError> {
        self.validate(order)?;
        let total = self.calculate_total(order);
        Ok(Receipt { total, items: order.items.clone(), status: Status::Paid })
    }

    fn validate(&self, order: &Order) -> Result<(), PaymentError> { ... }
    fn calculate_total(&self, order: &Order) -> Decimal { ... }
}

#[test]
fn test_process_payment_with_discount() {
    let order = Order { items: vec![Item::new("widget", 100)], discount: 0.1, currency: "USD" };
    let receipt = PaymentProcessor.process(&order).unwrap();
    assert_eq!(receipt.total, Decimal::new(9000, 2));
}
```

---

## Category 2: Local-substitutable dependencies

Dependencies with local test stand-ins (SQLite for Postgres, in-memory filesystem). Seam is **internal** — not exposed through the module's interface.

**Strategy**: Run stand-in in test suite. Test through public interface. Callers don't know or care which DB backs the module.

### Python

```python
# Deep module — DB choice is internal. Caller sees db_url string, not engine type.
class UserService:
    def __init__(self, db_url: str):
        self._engine = create_engine(db_url)

    def register(self, email: str, name: str) -> User: ...
    def find_by_email(self, email: str) -> User | None: ...

# Test with SQLite stand-in
@pytest.fixture
def user_service():
    return UserService(db_url="sqlite:///:memory:")

def test_register_and_find(user_service):
    user = user_service.register("alice@example.com", "Alice")
    found = user_service.find_by_email("alice@example.com")
    assert found.id == user.id
```

### Rust

```rust
// Deep module — DB is internal. Caller passes connection string, not pool type.
pub struct UserService {
    pool: sqlx::PgPool,  // internal detail
}

impl UserService {
    pub async fn new(database_url: &str) -> Result<Self, sqlx::Error> {
        let pool = sqlx::PgPool::connect(database_url).await?;
        Ok(Self { pool })
    }

    pub async fn register(&self, email: &str, name: &str) -> Result<User, ServiceError> { ... }
    pub async fn find_by_email(&self, email: &str) -> Result<Option<User>, ServiceError> { ... }
}

#[sqlx::test]
async fn test_register_and_find(pool: PgPool) {
    let svc = UserService { pool };
    let user = svc.register("alice@example.com", "Alice").await.unwrap();
    let found = svc.find_by_email("alice@example.com").await.unwrap();
    assert_eq!(found.unwrap().id, user.id);
}
```

---

## Category 3: Remote but owned (Ports & Adapters)

Your own services across a network boundary. Define a **port** at the seam. Two adapters = real seam.

**Strategy**: In-memory adapter for tests. HTTP/gRPC adapter for production.

### Python

```python
# Port
class InventoryPort(Protocol):
    def check_stock(self, sku: str) -> int: ...
    def reserve(self, sku: str, qty: int) -> ReservationId: ...

# Deep module
class OrderService:
    def __init__(self, inventory: InventoryPort):
        self._inventory = inventory

    def place_order(self, items: list[OrderItem]) -> Order:
        for item in items:
            if self._inventory.check_stock(item.sku) < item.qty:
                raise InsufficientStockError(item.sku)
            self._inventory.reserve(item.sku, item.qty)
        return Order(items=items, status="confirmed")

# In-memory adapter for testing
class InMemoryInventory:
    def __init__(self, stock: dict[str, int]):
        self._stock = dict(stock)
    def check_stock(self, sku: str) -> int: return self._stock.get(sku, 0)
    def reserve(self, sku: str, qty: int) -> ReservationId:
        self._stock[sku] -= qty
        return ReservationId(uuid4())

def test_place_order():
    inventory = InMemoryInventory({"WIDGET-1": 10})
    order = OrderService(inventory).place_order([OrderItem(sku="WIDGET-1", qty=3)])
    assert order.status == "confirmed"
    assert inventory.check_stock("WIDGET-1") == 7
```

### Rust

```rust
// Port
pub trait InventoryPort {
    fn check_stock(&self, sku: &str) -> Result<u32, InventoryError>;
    fn reserve(&self, sku: &str, qty: u32) -> Result<ReservationId, InventoryError>;
}

// Deep module
pub struct OrderService<I: InventoryPort> {
    inventory: I,
}

impl<I: InventoryPort> OrderService<I> {
    pub fn place_order(&self, items: &[OrderItem]) -> Result<Order, OrderError> {
        for item in items {
            if self.inventory.check_stock(&item.sku)? < item.qty {
                return Err(OrderError::InsufficientStock(item.sku.clone()));
            }
            self.inventory.reserve(&item.sku, item.qty)?;
        }
        Ok(Order { items: items.to_vec(), status: Status::Confirmed })
    }
}

// In-memory adapter for testing
struct InMemoryInventory { stock: RefCell<HashMap<String, u32>> }

impl InventoryPort for InMemoryInventory {
    fn check_stock(&self, sku: &str) -> Result<u32, InventoryError> {
        Ok(*self.stock.borrow().get(sku).unwrap_or(&0))
    }
    fn reserve(&self, sku: &str, qty: u32) -> Result<ReservationId, InventoryError> {
        *self.stock.borrow_mut().get_mut(sku).unwrap() -= qty;
        Ok(ReservationId::new())
    }
}

#[test]
fn test_place_order() {
    let inv = InMemoryInventory { stock: RefCell::new(HashMap::from([("WIDGET-1".into(), 10)])) };
    let svc = OrderService { inventory: inv };
    let order = svc.place_order(&[OrderItem { sku: "WIDGET-1".into(), qty: 3 }]).unwrap();
    assert_eq!(order.status, Status::Confirmed);
}
```

---

## Category 4: True external

Third-party services you don't control. Two strategies — pick based on whether the wrapper is reused across modules.

### Strategy A: Ports & Adapters (fake the port)

Narrow port exposing only what the module needs. Fake adapter in tests. Same pattern as Cat 3 — use when **multiple modules** consume the same external service through different ports.

### Python

```python
# Narrow port
class PaymentGateway(Protocol):
    def charge(self, amount_cents: int, token: str) -> ChargeResult: ...
    def refund(self, charge_id: str) -> RefundResult: ...

# Deep module
class BillingService:
    def __init__(self, gateway: PaymentGateway):
        self._gateway = gateway

    def bill_customer(self, invoice: Invoice, token: str) -> Payment:
        result = self._gateway.charge(invoice.total_cents, token)
        if not result.success:
            raise PaymentFailedError(result.error)
        return Payment(charge_id=result.charge_id, amount=invoice.total_cents)

# Fake adapter
class FakePaymentGateway:
    def __init__(self): self.charges, self.should_fail = [], False
    def charge(self, amount_cents: int, token: str) -> ChargeResult:
        self.charges.append((amount_cents, token))
        if self.should_fail: return ChargeResult(success=False, error="declined")
        return ChargeResult(success=True, charge_id=f"ch_{len(self.charges)}")
    def refund(self, charge_id: str) -> RefundResult: return RefundResult(success=True)

def test_bill_customer():
    gw = FakePaymentGateway()
    payment = BillingService(gw).bill_customer(Invoice(total_cents=5000), "tok_valid")
    assert payment.amount == 5000 and len(gw.charges) == 1
```

### Rust

```rust
// Narrow port
pub trait PaymentGateway {
    fn charge(&self, amount_cents: u64, token: &str) -> Result<ChargeResult, GatewayError>;
    fn refund(&self, charge_id: &str) -> Result<RefundResult, GatewayError>;
}

// Deep module
pub struct BillingService<G: PaymentGateway> { gateway: G }

impl<G: PaymentGateway> BillingService<G> {
    pub fn bill_customer(&self, invoice: &Invoice, token: &str) -> Result<Payment, BillingError> {
        let result = self.gateway.charge(invoice.total_cents, token)?;
        if !result.success { return Err(BillingError::Declined(result.error)); }
        Ok(Payment { charge_id: result.charge_id, amount: invoice.total_cents })
    }
}

// Fake adapter
struct FakeGateway { should_fail: bool, charges: RefCell<Vec<(u64, String)>> }

impl PaymentGateway for FakeGateway {
    fn charge(&self, amount: u64, token: &str) -> Result<ChargeResult, GatewayError> {
        self.charges.borrow_mut().push((amount, token.to_string()));
        if self.should_fail { return Ok(ChargeResult { success: false, error: "declined".into() }); }
        Ok(ChargeResult { success: true, charge_id: format!("ch_{}", self.charges.borrow().len()) })
    }
    fn refund(&self, _: &str) -> Result<RefundResult, GatewayError> { Ok(RefundResult { success: true }) }
}

#[test]
fn test_bill_customer() {
    let gw = FakeGateway { should_fail: false, charges: RefCell::new(vec![]) };
    let svc = BillingService { gateway: gw };
    let payment = svc.bill_customer(&Invoice { total_cents: 5000 }, "tok_valid").unwrap();
    assert_eq!(payment.amount, 5000);
}
```

### Strategy B: Nullable Infrastructure (self-simulating wrapper)

Infrastructure wrapper has a `create_null()` factory that returns a real instance with I/O disabled. No DI, no ports — the wrapper **knows how to simulate itself**. Use when the wrapper is **owned by one module** and port abstraction adds unnecessary indirection.

Composed from four sub-patterns:
- **Embedded Stub** — stub of third-party code lives inside the wrapper (not in test files)
- **Configurable Responses** — `create_null()` accepts params controlling return values
- **Output Tracking** — wrapper emits events on writes; tests subscribe via `track_output()`
- **Behavior Simulation** — methods like `simulate_event()` trigger incoming events without real I/O

#### Python

```python
# Production wrapper — self-simulating
class PaymentClient:
    def __init__(self, api_key: str, *, _http=None):
        self._http = _http or httpx.Client(base_url="https://api.stripe.com")
        self._api_key = api_key
        self._tracked: list[dict] | None = None

    @classmethod
    def create_null(cls, *, charges: list[ChargeResult] | None = None) -> "PaymentClient":
        """Null instance — no network, configurable responses."""
        stub_responses = iter(charges or [ChargeResult(success=True, charge_id="ch_null")])
        instance = cls.__new__(cls)
        instance._api_key = "null"
        instance._http = None  # no real client
        instance._stub_responses = stub_responses
        instance._tracked = None
        return instance

    def charge(self, amount_cents: int, token: str) -> ChargeResult:
        if self._http is None:  # nulled
            result = next(self._stub_responses)
        else:
            resp = self._http.post("/charges", json={"amount": amount_cents, "token": token})
            result = ChargeResult.from_response(resp)
        if self._tracked is not None:
            self._tracked.append({"type": "charge", "amount": amount_cents, "token": token})
        return result

    def track_output(self) -> list[dict]:
        self._tracked = []
        return self._tracked

# Deep module — no DI, creates own dependency
class BillingService:
    def __init__(self, payment: PaymentClient | None = None):
        self._payment = payment or PaymentClient(os.environ["STRIPE_KEY"])

    def bill_customer(self, invoice: Invoice, token: str) -> Payment:
        result = self._payment.charge(invoice.total_cents, token)
        if not result.success:
            raise PaymentFailedError(result.error)
        return Payment(charge_id=result.charge_id, amount=invoice.total_cents)

# Test — no mocks, no fakes, no DI framework
def test_bill_customer():
    client = PaymentClient.create_null()
    tracked = client.track_output()
    svc = BillingService(payment=client)
    payment = svc.bill_customer(Invoice(total_cents=5000), "tok_valid")
    assert payment.amount == 5000
    assert tracked == [{"type": "charge", "amount": 5000, "token": "tok_valid"}]

def test_bill_customer_declined():
    client = PaymentClient.create_null(
        charges=[ChargeResult(success=False, error="declined")]
    )
    svc = BillingService(payment=client)
    with pytest.raises(PaymentFailedError):
        svc.bill_customer(Invoice(total_cents=5000), "tok_bad")
```

#### Rust

```rust
// Production wrapper — self-simulating
pub struct PaymentClient {
    api_key: String,
    http: Option<reqwest::Client>,       // None when nulled
    stub_responses: Option<Vec<ChargeResult>>,
    tracked: Option<Arc<Mutex<Vec<TrackEntry>>>>,
}

impl PaymentClient {
    pub fn new(api_key: &str) -> Self {
        Self { api_key: api_key.into(), http: Some(reqwest::Client::new()),
               stub_responses: None, tracked: None }
    }

    pub fn create_null(charges: Vec<ChargeResult>) -> Self {
        Self { api_key: "null".into(), http: None,
               stub_responses: Some(charges), tracked: None }
    }

    pub fn track_output(&mut self) -> Arc<Mutex<Vec<TrackEntry>>> {
        let tracker = Arc::new(Mutex::new(vec![]));
        self.tracked = Some(tracker.clone());
        tracker
    }

    pub fn charge(&mut self, amount_cents: u64, token: &str) -> Result<ChargeResult, ClientError> {
        let result = if let Some(ref mut stubs) = self.stub_responses {
            stubs.remove(0) // nulled: return stub
        } else {
            // real HTTP call
            todo!("real implementation")
        };
        if let Some(ref tracker) = self.tracked {
            tracker.lock().unwrap().push(TrackEntry::Charge { amount_cents, token: token.into() });
        }
        Ok(result)
    }
}

// Deep module
pub struct BillingService { payment: PaymentClient }

impl BillingService {
    pub fn new(payment: PaymentClient) -> Self { Self { payment } }

    pub fn bill_customer(&mut self, invoice: &Invoice, token: &str) -> Result<Payment, BillingError> {
        let result = self.payment.charge(invoice.total_cents, token)?;
        if !result.success { return Err(BillingError::Declined(result.error)); }
        Ok(Payment { charge_id: result.charge_id, amount: invoice.total_cents })
    }
}

#[test]
fn test_bill_customer() {
    let mut client = PaymentClient::create_null(vec![
        ChargeResult { success: true, charge_id: "ch_null".into(), error: String::new() },
    ]);
    let tracked = client.track_output();
    let mut svc = BillingService::new(client);
    let payment = svc.bill_customer(&Invoice { total_cents: 5000 }, "tok_valid").unwrap();
    assert_eq!(payment.amount, 5000);
    assert_eq!(tracked.lock().unwrap().len(), 1);
}
```

### When to pick A vs B

| Signal | Strategy A (Ports) | Strategy B (Nullable) |
|--------|-------------------|----------------------|
| Multiple modules use different slices of the service | ✅ Narrow ports per consumer | Wrapper gets bloated |
| Single module owns the external call | Over-engineered | ✅ Simpler, no DI |
| Need runtime adapter swapping (e.g. multi-tenant) | ✅ Inject at runtime | Not designed for this |
| Wrapper useful in production dry-run mode | Works but separate concern | ✅ `create_null()` serves both |

---

## General principles

- **Replace, don't layer.** Old shallow-module tests become waste once deepened-interface tests exist — delete them.
- **Interface is the test surface.** Assert on observable outcomes, not internal state.
- **Tests survive refactors.** If a test breaks when implementation changes, it tests past the interface.
- **Functional core, imperative shell.** Push decisions into pure functions (the core), push I/O to the edges (the shell). Core is trivially testable — pass values in, assert values out. Shell is thin enough to verify by inspection or integration test. When a module mixes decisions and effects, extract the decision logic into a pure function first.
- **Fake the port, not the HTTP client.** Narrow ports make fakes simple. Mocking `reqwest`/`httpx` tests transport, not logic.
- **Prefer stubs/fakes/spies/nullables over mocks.** Fakes maintain state and catch interaction bugs mocks miss. Stubs provide canned answers. Spies record calls for later assertion. Nullable wrappers self-simulate. All avoid the brittle coupling of mock expectations.
- **Mocks only when call ordering IS the behavior.** Protocol correctness (e.g., "must call `begin` before `commit`"), interaction semantics that can't be observed through return values — these are legitimate mock territory. Everything else: use a simpler test double.
- **Never mock what you own.** If you wrote the class, make it testable directly (deepen, nullable, or stand-in). Mocks are a last resort for code you can't change.

### Test double hierarchy

Pick the **simplest double** that validates the behavior:

| Double | What it does | When to use |
|--------|-------------|-------------|
| **Stub** | Returns canned values | Read-only dependency, you only care about the response |
| **Fake** | Maintains state, simplified impl | Need realistic stateful behavior (in-memory DB, etc.) |
| **Spy** | Records calls, asserts after | Need to verify a side effect happened (email sent, event emitted) |
| **Nullable** | Self-simulating production wrapper | External I/O, single owner, want production-grade test double |
| **Mock** | Verifies call order + args eagerly | Call ordering/protocol IS the behavior under test |
