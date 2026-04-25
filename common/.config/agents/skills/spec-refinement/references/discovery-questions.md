# Discovery Questions

Prompts for Step 2. Not a checklist — pick what's relevant. Goal is shared understanding, not exhaustive coverage.

## Problem Space

- What triggered this work? (Bug report, user feedback, tech debt, new capability?)
- Who are the users/consumers? Internal team, end users, other services?
- What's the cost of NOT doing this?
- Is there an existing workaround? What's wrong with it?

## Behavior

- Walk me through the happy path, step by step
- What inputs? What outputs? What side effects?
- What error cases matter? What should happen for each?
- What existing behavior must NOT change?
- Are there performance/latency requirements?

## Boundaries

- What's explicitly out of scope for this iteration?
- What's the smallest useful version? (Tracer bullet / walking skeleton)
- Are there phases? What's phase 1 vs later?
- What dependencies exist? (Other teams, services, migrations)

## Constraints

- Timeline — hard deadline or flexible?
- Technical constraints — language, framework, infrastructure locked in?
- Compliance / security requirements?
- Backwards compatibility requirements?

## Integration

- What existing modules/services does this touch?
- What APIs need to change? What's the blast radius?
- How will this be tested? (Unit, integration, E2E, manual?)
- How will this be deployed? (Feature flag, migration, breaking change?)
