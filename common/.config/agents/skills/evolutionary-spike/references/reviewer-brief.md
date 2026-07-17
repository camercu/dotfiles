# Reviewer brief template

Dispatch to a FRESH agent that did NOT author the spike(s) (reviewer ≠ author).
Fill `{{slots}}`, adapt with judgment.

---

You are a fresh, independent reviewer in `{{repo}}` on `{{branch}}`. You did NOT
write this code — review it critically. Toolchain: `{{how-to-run-tools}}`. Do NOT
switch branches or commit.

## Review these
{{spike file(s) / branch(es)}} — prototypes that {{one-line goal}}.

## Check
1. **Correctness** — logic bugs, wrong assertions, panic/overflow, behavior
   contradicting the file's own doc.
2. **Honesty of EVERY claim** — verify each cost/property claim against the code
   (no hidden `Rc`/alloc, no unsafe, no unstable feature, no lying stub, no
   oversell). A comment that oversells is a defect here.
3. **The decisive property** — {{the key question}}. RE-RUN the proof yourself
   (e.g. the compile-gate probe): capture the exact result, then revert.
4. **Cleanliness** — {{lint/format command}}, dead code, unused imports, needless
   complexity.

## Apply fixes
Fix CLEAR findings directly (lint, false/stale comment, dead code, demonstrably
wrong claim), minimal and in-style. Don't change the fundamental design. REPORT
judgment-dependent items instead of editing. Don't commit.

## Report
(1) ranked findings (severity, file:line, FIXED vs REPORTED); (2) honesty verdict
per claim; (3) the proof result you saw; (4) verification after fixes; (5) any
residual concern for adopting this design.
