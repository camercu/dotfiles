# Soundness

Runs in the implementing context: it enumerates this change's invariants.

1. List every operation in the change that carries a precondition the
   toolchain won't verify: unsafe/FFI/raw pointer, shared mutable state,
   concurrency, privilege boundary, call-order lifecycle, permission check.
2. Give each exactly one status:
   - **upheld internally** for every input and state, with the argument; or
   - **pushed to the caller** by a fail-closed mechanism — signature that marks
     the obligation (Rust `unsafe fn`), typed precondition, or runtime guard
     that rejects bad input — **and** documented at the site.
3. Hunt the headline smell: a normal-looking public surface (no warning in its
   signature) hiding a precondition it cannot enforce. Fix: guard it, or make
   the signature announce the obligation.
4. A wrapper implying a guarantee it does not uphold → fix it or delete it.
5. Every safety claim in docs or comments ("confined to X", "always
   single-threaded", "callers must…") = checkable invariant. Verify against
   code; fix whichever side is wrong.
6. Change adds a precondition marker or fail-closed guard to a **public**
   contract → breaking change → gate. Internal-only → record the decision
   (rule 3).

Done when every listed operation has one status with evidence in findings.
