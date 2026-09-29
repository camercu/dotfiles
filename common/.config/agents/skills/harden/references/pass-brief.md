# Pass brief

Prompt for every fresh agent harden spawns. Fill `<…>`; include only the
section for this pass.

## Common

```
Task: <pass> pass for harden, round <n>. Invoke the `<skill>` skill via the
Skill tool and run it over the scope below.
Scope: commits <base>..<head> (`git log --oneline <base>..<head>`).
Verify: <matrix commands, one per line>.
Authority docs: <paths>. A finding that would reverse one → report it as a
conflict with the doc quote; leave the doc as is.
Findings file: <repo>/.harden/<pass>-r<n>.md. Follow
~/.config/agents/record-as-you-go.md; the file is the deliverable.
Rails: read-only on tracked files; history stays as is (no rebase, amend,
reset). Skill step says fix → write the fix as a finding with the proposed
diff; harden's main context lands it. Skill step asks the user → write the
question, options, and your recommendation as a finding; continue.
Leave unread: .harden/LEDGER.md and other passes' findings files — they
would prime you.
Report: path to findings file; each finding ranked, with file:line, evidence,
and significant / cosmetic / false-positive.
```

## Review — add

```
Two lenses:
1. Inside the box: bugs, regressions, coverage gaps (untested wiring is the
   classic miss), security, design as written. Mutation tool present → run it
   over the range; each survivor = candidate finding. Each finding: name its
   class and sweep for siblings.
2. First principles: treat current shape as accidental. Rebuilt from scratch,
   what would never get built? Hunt reframings that preserve behaviour and
   delete whole branches, helpers, or concepts. Challenge each abstraction,
   each special case in an unrelated flow, each misplaced layer, each loose
   type a sharper model would forbid, each file or function grown past what a
   reader holds. A documented decision can be the defect: say so.
Reframing too big for one slice → report it as a plan candidate.
```

## Convergence — replaces the task line

Give only what is below. Fix rationale and your own probes stay out:
overlapping probes are the point.

```
Task: convergence check for harden. Treat the change as new to you.
1. Invoke `dogfood` on the change (adversarial pass included).
2. Invoke `code-review` over the range, both lenses above.
3. Run every matrix command; report exit status each.
Original friction report: <path> — confirm each item resolved or still live.
Verdict line: "converged" (zero significant findings) or "not converged:
<count> significant".
```
