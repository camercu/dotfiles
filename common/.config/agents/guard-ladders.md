# Guard ladders

Specializes *Defect prevention* tier 2 (AGENTS.md) for two reflexes: test that
reads text, doc that mirrors code.

## Test guards

Test guard = test that scans source or config text for a pattern (grep `/tmp`
in `src/`, recipe must contain `--all-targets`, no `return` under a privilege
check). Checks spelling, not meaning: misses next spelling of same mistake,
flags harmless one, breaks on reword. Each missed shape grows scanner; next
shape still gets through. Order:

1. **Structure.** Remove second copy or make bad state impossible: one source
   (build arg, generated file, shared type); compare what code *does* (file
   identity, not path spelling).
2. **Behavior.** Tier that runs code and fails on the mistake: platform without
   `/tmp`, packaged crate built and tested, resolved dependency graph. "Can this
   test fail at all?" → mutation testing over the change (`cargo mutants
   --in-diff`), not meta-test that scans test shapes.
3. **Review.** Rule about code or config shape (which flag, where a name may
   appear): state once at the site or in the ADR; reviewer reads the diff.
   Scanner sees nothing reviewer doesn't.

Text guard = last resort: fact must hold, no tier above reaches, silent drift
expensive. Test records why the three above did not reach.

## Docs drift

Doc contradicts code = defect. Guard test comparing prose to source = brittle
tier 2: parses wording, breaks on reword, freezes doc shape. Tier 1 first:

1. **Say less.** Name rule, not enumeration. "`pub fn` wherever the capability
   table grants `thread_count`" cannot go stale; list of five platforms goes
   stale when table grows. Doc that omits volatile fact cannot state it wrong.
2. **Generate it.** Detail must appear AND changes often → generate from source
   of truth (build script, doc macro, `include_str!`, codegen). One copy,
   nothing to drift.

Prose guard test = last resort: fact must be stated, cannot be generated,
silent drift expensive. Test records why the two moves above did not reach.
