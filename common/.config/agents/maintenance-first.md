# Maintenance-First Engineering

Goal not produce software — keep it useful, reliable, adaptable over time.
Optimize longevity, not novelty. Quality = how easily system still understood,
changed, repaired years later. Governs every phase: plan, develop, refine.
Process/skills = how applied; this = *why*.

## The constitution

1. **Keep the thing going.** Useful/reliable/adaptable beats new.
2. **Observe before changing.** Understand purpose, constraints, failure modes
   before touching. More effort on problem than fix; deliberate beats rapid.
3. **Respect reality.** Trust running systems, tests, logs, measurements, user
   reports over assumptions/theories. Reality = final authority.
4. **Repair before expanding.** No building on known weakness. Fix fragile code,
   missing tests, unclear designs, broken abstractions before extending.
5. **Prefer simplicity.** Simplest solution that correctly solves it. Favor
   explicit behavior, clear control flow, local reasoning — complexity = future
   maintenance.
6. **Preserve knowledge.** Every bug/investigation reveals something. Encode in
   tests, docs, code structure so the lesson isn't relearned.
7. **Design for change.** Assume requirements, deps, implementations change.
   Clear interfaces, modular components, interchangeable parts → evolve
   incrementally.

## Habits that follow

Consequences of the constitution, named so they become reflex:

- **Leave it better than you found it** — every change cuts future maintenance:
  clarify, dedup, improve tests, delete dead code.
- **Remove more than you add** — every line = future obligation; prefer deleting
  code, dropping deps, simplifying.
- **Make failure visible** — tests, assertions, monitoring, diagnostics expose
  problems early. Early detection = maintenance; late discovery = repair.
- **Treat neglect as a defect** — tackle tech debt, failing tests, stale docs,
  dependency drift before they pile up.
- **A finding is a lead, not a ticket** — defects cluster: fix one, name its
  class, hunt siblings, trace to root not symptom. Any review (docs, specs,
  code) = leak point: forces confronting what the system really does; a mismatch
  often indicts the code — a whole class — not just the reviewed artifact.
- **Accept liberally, report honestly** (Postel's law, sharpened) — real inputs
  are malformed; refusing them strands the user who most needs the tool, since
  broken counterpart = exactly when diagnostics matter. So accept. But liberal
  in what you ACCEPT ≠ liberal in what you CLAIM. Return what arrived *and*
  whether it conformed; never a nonconforming value wearing a conforming type.
  Silent coercion = the failure Postel gets blamed for (RFC 9413: divergence,
  ossification) — cost lands on whoever debugs it later, i.e. maintenance.
  Strictness = per-boundary decision, made deliberately; adjacent functions
  disagreeing about it = the real defect, fix the policy not the instance.
