# Dependency Categories & Proposal Template

## The Four Categories

### 1. In-process

Pure computation, in-memory state, no I/O. Always deepenable — merge the modules and test directly. No Shore patterns needed.

### 2. Local-substitutable

Dependencies with local test stand-ins (e.g., SQLite for Postgres, in-memory filesystem, fake clock). The deepened module is tested with the stand-in running in-process.

**Shore patterns to consider:** Infrastructure Wrappers, Narrow Integration Tests, Nullables + Configurable Responses for non-determinism (time, randomness).
See [shores-patterns.md](shores-patterns.md) → Foundational & Infrastructure sections.

### 3. Remote but owned (Ports & Adapters)

Your own services across a network boundary (microservices, internal APIs). Define a port (interface) at the module boundary. The deep module owns the logic; the transport is injected. Tests use an in-memory adapter; production uses the real adapter.

**Shore patterns to consider:** A-Frame Architecture, Infrastructure Wrappers, Nullables + Fake It Once You Make It, Output Tracking for side effects.
See [shores-patterns.md](shores-patterns.md) → Architectural & Nullability sections.

### 4. True external (Mock boundary)

Third-party services (Stripe, SendGrid, etc.) you don't control. Mock at the boundary. The deepened module takes the external dependency as an injected port; tests provide a Nullable or mock implementation.

**Shore patterns to consider:** Infrastructure Wrappers with Embedded Stub, Nullables + Configurable Responses + Output Tracking + Behavior Simulation.
See [shores-patterns.md](shores-patterns.md) → Nullability section.

## Testing Strategy

Core principle: **replace, don't layer.**

- Old unit tests on shallow modules are waste once boundary tests exist — delete them
- Write new tests at the deepened module's interface boundary
- Tests assert on observable outcomes through the public interface, not internal state
- Tests survive internal refactors — they describe behavior, not implementation

## Proposal Template

Use this template in Step 7 to present the final proposal in chat:

---

### Problem

- Which modules are shallow and tightly coupled
- What integration risk exists at their seams
- Why this makes the codebase harder to navigate and test

### Proposed Interface

- Interface signature (types, methods, params)
- Usage example showing how callers use it
- What complexity it hides internally

### Dependency Strategy

Which category applies and how dependencies are handled:

- **In-process**: merged directly
- **Local-substitutable**: tested with [specific stand-in] + Shore patterns used
- **Ports & adapters**: port definition, production adapter, in-memory test adapter + Shore patterns used
- **Mock/Nullable boundary**: Nullable design, Configurable Responses, Output Tracking + Shore patterns used

### Testing Strategy

- **New boundary tests to write**: behaviors to verify at the interface
- **Old tests to delete**: shallow module tests that become redundant
- **Test environment needs**: stand-ins, adapters, Nullable factories required

### Implementation Recommendations

Durable guidance NOT coupled to current file paths:

- What the module should own (responsibilities)
- What it should hide (implementation details)
- What it should expose (the interface contract)
- How callers should migrate to the new interface
