# Tracer Bullets & Walking Skeleton

## Tracer Bullet (Pragmatic Programmer)

Build a tiny, end-to-end slice of the feature first. Seek feedback. Then expand.

A tracer bullet goes through all layers of the system — UI/API, logic, infrastructure — in the thinnest possible slice. It validates the architecture, proves the path works, and gives early feedback before committing to full implementation.

**Not a prototype.** Tracer bullet code is production code — thin but real. A prototype is throwaway.

## Walking Skeleton (Cockburn)

The **first** tracer bullet that also establishes the deployment pipeline. A walking skeleton is a tiny implementation that:

1. Exercises all architectural layers end-to-end
2. Is deployable (builds, tests pass, can be deployed to a real environment)
3. Proves the infrastructure works (CI, packaging, deployment)

Build the walking skeleton before fleshing out features. It de-risks the architecture and the deployment pipeline simultaneously.

## In TDD

The tracer bullet is your first acceptance test + the minimal implementation that makes it pass. Each subsequent acceptance test adds another vertical slice. The system grows outward from a working core, never from disconnected pieces assembled at the end.

```
Walking skeleton:     [  thin slice through all layers  ] → deploy
Tracer bullet 1:      [  first feature, thin slice      ] → acceptance test passes
Tracer bullet 2:      [  second feature, thin slice     ] → acceptance test passes
Flesh out:            [  edge cases, error handling     ] → coverage audit
```
