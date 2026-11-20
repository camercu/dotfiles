---
name: benchmark
description: Use when measuring performance, investigating performance regressions, comparing throughput or latency, or verifying an optimization claim.
---

# Benchmark

1. Define the workload, metric and unit, correctness assertion, and practical
   effect size. Record commands, inputs and sizes, revisions, build options,
   toolchain, hardware, environment, and cold or warm state.
2. Run the baseline and candidate under comparable conditions. Verify outputs
   and exit status. Preserve the raw measurements and logs. Keep workload or
   environment differences explicit and test them separately when possible.
3. For a decision between alternatives, repeat both runs and alternate order
   where practical. Report sample count, median, spread, and absolute and
   relative change. Inspect warmup, caches, background load, and outliers.
   If variation obscures the effect, record the comparison as inconclusive.
   A single run can support a rough estimate labeled as such.
4. Explain the result. Use profiling or resource counters where feasible to
   identify the limiting resource or code path. Check an end-to-end workload
   when a microbenchmark is being used to justify a user-facing claim.

Done when a reader can rerun the same workload, check correctness, and tell
whether the measured effect exceeds the observed noise and matters in use.
