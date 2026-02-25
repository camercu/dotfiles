# review checklists

Use these checklists during refinement and before task completion.

## Red-team design checklist

1. Does every abstraction solve a concrete problem requirement?
2. Is any layer present only because a methodology prefers it?
3. Are there ambiguous requirements that can be interpreted in two ways?
4. Are there hidden dependencies or state coupling across modules?
5. Can each critical behavior be tested in realistic conditions?
6. Are proposed error-injection hooks limited to hard-to-trigger failures?
7. Is complexity reduced or unchanged versus the previous iteration?
8. Can a fresh-session agent implement from the spec without chat history?

## Spec compliance checklist

1. Does the implementation satisfy each cited requirement ID exactly?
2. Are edge cases explicitly covered where the spec requires them?
3. Are any behaviors added that conflict with requirement boundaries?
4. Is error behavior aligned with architectural error semantics?
5. Is backward compatibility preserved where required?

## Code quality checklist

1. Are there correctness bugs, regressions, or race conditions?
2. Are there missing tests for new behavior and critical edge cases?
3. Is code clear enough to maintain without hidden coupling?
4. Are risky assumptions documented and guarded?
5. Does the change preserve or improve observability and diagnosability?
