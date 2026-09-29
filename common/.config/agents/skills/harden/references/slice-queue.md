# Slice queue

Scope = whole repo, or wider than one context window. One monolithic pass
overruns context; the queue splits it.

1. **Survey** cheap signals: public-surface map, module sizes, churn (`git log
   --stat --since=6.months`), past defect clusters (`git log --grep=fix`),
   unchecked-invariant surface (unsafe, concurrency, FFI, privilege),
   doc-vs-code staleness, coverage gaps.
2. **Slice** into bounded areas (module, subsystem, consumer workflow), each
   small enough to finish inside one context window.
3. **Rank**, riskiest and most valuable first: consumer-surface breadth,
   correctness risk, churn × complexity, test and doc staleness. One-line why
   per rank.
4. **Gate**: present ranked slices + why. Scope and order = user's call.
   Record the verdict in the ledger *Slices* table.
5. **Run** steps 1–5 per slice, scoped to it. Checkpoint at slice end.
   Cross-slice finding → new queue entry, re-ranked, left for its own slice.

Done when every queue entry is `done` or `declined` in the ledger.
