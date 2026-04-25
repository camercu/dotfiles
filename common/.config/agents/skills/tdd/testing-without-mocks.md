# Testing Without Mocks

James Shore's pattern language for fast, state-based tests without mock frameworks. Full reference: [Testing Without Mocks](https://www.jamesshore.com/v2/projects/nullables/testing-without-mocks).

## Core Principles

- **Narrow tests** — test small slices of behavior, not the whole system.
- **State-based by default** — assert on outputs/state, not on how collaborators were invoked. If behavior isn't observable, fix the design (return values, getters, events). Exception: when call ordering/protocol IS the behavior under test (see Decision Rule 7).
- **Overlapping sociable tests** — use real collaborators, not mocks. Tests overlap across layers. Isolate only at true infrastructure boundaries via nullables.
- **Smoke tests** — a few broad "does it basically run?" checks. Keep few and stable.

## Architecture: Functional Core, Imperative Shell

Shore's **A-Frame Architecture** separates logic from infrastructure as peers, not layers:

```
        ┌─────────────┐
        │ Application  │  ← coordinates, thin
        ├──────┬───────┤
        │ Logic│ Infra  │  ← peers, no deps between them
        └──────┴───────┘
```

Two coordination patterns:

**Logic Sandwich** — read from infra → process in logic → write via infra. Test logic with values, test infra with nullables.

**Traffic Cop** — for event-driven systems. Application subscribes to events from infra/logic; each event triggers a mini sandwich.

**Grow Evolutionary Seeds** — start with trivial Application-layer class, hard-code one infra value, test-drive, then refactor into Logic + Infrastructure as complexity grows.

## Logic Patterns

- **Easily-Visible Behavior** — make results observable. Prefer pure functions. For OO, prefer immutability; provide getters or events for state changes.
- **Testable Libraries** — wrap third-party code behind your-app-shaped API. If it touches external systems, treat as infrastructure instead.
- **Collaborator-Based Isolation** — keep tests narrow by focusing on specific behavior, treating collaborator results as "given." Use sparingly — tightens coupling to structure.

## Infrastructure Patterns

- **Infrastructure Wrappers** — one wrapper per external system with a clean domain-facing API. The wrapper's API matches what your application needs, not what the external system provides.
- **Narrow Integration Tests** — verify real infrastructure communication. One behavior/edge-case at a time. Keep focused and few. Run against real external systems.
- **Verified Fakes** — run the same contract tests against both the real implementation and the fake. If both pass, the fake is trustworthy. If the real impl changes behavior, contract tests fail against the fake, forcing you to update it. Unverified fakes silently drift from reality. Only skip verification for scenarios hard to reproduce reliably (network failures, timeouts).
- **Paranoic Telemetry** — diagnostic hooks around external calls. Helps confirm assumptions your stubs rely on.

## Nullable Patterns

The core innovation. Make infrastructure testable without mocks by providing "real-but-disabled" instances.

### Nullables

Provide `create()` (real) and `create_null()` (nulled) factories. Nulled instances:
- Return safe defaults, perform no external I/O
- Execute your production logic paths
- Are production-grade code (usable for dry runs), not just test helpers

### Embedded Stub

Stub the third-party boundary inside the wrapper, not your own code. Minimal stub of the external API lives in the production file. Test-drive through wrapper's public API. Validate against real system with narrow integration tests.

### Thin Wrapper

When you can't embed a stub (interface too broad, language needs explicit interfaces): define your own small interface matching only the methods you use. Real adapter + stub implementation.

### Configurable Responses

`create_null()` accepts params controlling return values in **domain-level** terms:

```python
# Good: domain-level config
client = UserClient.create_null(users=[User(name="Alice", verified=True)])

# Bad: implementation-level config
client = UserClient.create_null(http_responses=[Response(200, '{"name":"Alice"}')])
```

Support sequences (list that exhausts) and constants (repeat forever).

### Output Tracking

Track writes as **domain-level events**, not raw call logs:

```python
client = EmailClient.create_null()
tracked = client.track_output()
send_welcome(client, user)
assert tracked == [{"type": "welcome_email", "to": "alice@example.com"}]
```

Works in both nulled and real mode. Replaces mock verification.

### Behavior Simulation

Simulate incoming events without real infrastructure:

```python
ws = WebSocket.create_null()
ws.simulate_message({"type": "chat", "text": "hello"})
# triggers same internal handler as real message
```

Share implementation between real event handler and simulation method.

### Fake It Once You Make It

For higher-level code: implement `create_null()` by composing nulled dependencies. Use real production logic. Add configurable responses / output tracking / behavior simulation only where needed.

## Legacy Migration

### Descend the Ladder
Convert module + direct dependencies, not deeper. Work downward incrementally. Use throwaway stubs temporarily for unconverted deep deps.

### Climb the Ladder
For small dependency trees: convert bottom-up quickly without throwaway stubs.

### Replace Mocks with Nullables
1. Replace mock return configs → Configurable Responses
2. Replace event setups → Behavior Simulation
3. Replace call assertions → Output Tracking (do last)

## Decision Rules

1. Default to **narrow + state-based** tests.
2. Pure logic → test directly with values. No doubles needed.
3. Mixed logic + IO → extract pure function first (functional core).
4. Infrastructure dep → **Infrastructure Wrapper + Narrow Integration Tests**, then make **Nullable** via Embedded Stub / Thin Wrapper.
5. Higher layers → nullable by composition (Fake It Once You Make It). Add configurable responses / output tracking / behavior simulation only as needed.
6. Use **A-Frame + Sandwich/Traffic Cop** for architecture-level decoupling.
7. **Don't mock what you don't own.** Mock your own abstractions (facades, wrappers), not third-party APIs directly. Mocking `requests`/`reqwest` creates brittle, boilerplate-heavy tests that obscure intent. Wrap the external dep in a domain-facing facade, then mock/fake/stub that. Mocks are legitimate when **call ordering IS the behavior** — protocol correctness ("must call `begin` before `commit`", "must not call `send` after `close`"), interaction semantics not observable through return values. Everything else: use a simpler double.
