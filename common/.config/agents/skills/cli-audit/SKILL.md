
---
name: cli-audit
description: Use when reviewing a proposed or implemented command-line interface, asked for a CLI review, command ergonomics review, command taxonomy review, CLI usability audit, composability or grep-ability review, or Command Line Interface Guidelines compliance check. Also runs from cli-design and dogfood for CLI targets. For general consumer trials, use dogfood.
---

# CLI audit

## Overview

Evaluate CLI usability, conceptual integrity, composability, and public
contracts against `cli-design`, CLIG, and Norman's action cycle.
Produce severity-ranked findings with evidence and concrete proposed
corrections. Implementation belongs to `cli-design` and `tdd`.

## Context

- Read [cli-design](../cli-design/SKILL.md), specifically *Context*,
  *Plan*, and *Design rules*. The design rules are the shared source
  of truth.
- Read [Command Line Interface Guidelines](https://clig.dev/) (CLIG).
  Account for every applicable guideline during the audit.
- Read approved requirements, design documents, workflow tests, entry
  documentation, and relevant domain conventions.
- Establish existing consumers and compatibility obligations before
  recommending public interface changes.
- For implemented CLIs, build and launch the intended revision through
  the project's documented procedure or `run` skill.
- Reuse applicable `dogfood` evidence for the same revision,
  configuration, and workflow.
- Apply approved requirements as design authority, actual executions
  as behavioral evidence, and source inspection for causes and
  unexercised paths. Record contradictions as findings.

## Modes

- **Design:** Evaluate proposed interfaces, command specifications,
  transcripts, help drafts, output contracts, and conceptual models.
  Use cognitive walkthroughs and concrete alternative transcripts.
  Mark runtime behavior and human usability as unverified.
- **Implementation:** Evaluate the real executable, documented
  contract, and observed behavior. Exercise workflows and process
  boundaries with independent consumers.
- **Re-evaluation:** Reproduce prior findings and affected workflows.
  Report resolved, still-live, regressed, and new findings. Expand
  coverage when changes affect additional public contracts.

Select design or implementation mode according to available artifacts.
Use both when an existing executable implements only part of a proposed
interface. Report coverage separately.

**Report-only.** Keep tracked files unchanged. Use disposable fixtures,
isolated configuration, and simulated infrastructure for consequential
probes. Obtain approval before interacting with real external systems
or performing irreversible actions.

## Steps

Open `.scratch/cli-audit/<run>/report.md` before step 1. Record evidence
per `~/.config/agents/record-as-you-go.md`.

### 1. Inventory the public surface

- For a full audit, enumerate all commands and workflows.
- For a change audit, enumerate affected workflows and shared contracts,
  including sibling commands affected by consistency or compatibility.
- Reconcile specifications, recursive help, documentation, parser
  definitions, acceptance tests, configuration, and public output
  contracts as available.
- Record undocumented capabilities and documented capabilities without
  implementation or verification.
- Include inherited flags, environment variables, context resolution,
  supported input and output formats, schemas, exit statuses, and
  persistent side effects where applicable.
- Identify every command producing data, including commands that
  produce streaming, tabular, structured, or binary results.

The inventory is the coverage tracker for subsequent steps.

For a cold or independent walkthrough, derive the initial inventory
from user-facing artifacts. Defer source inspection until after the
docs-first walkthrough in step 3, then reconcile the inventory against
the implementation.

### 2. Evaluate the conceptual model

Describe user-facing objects, actions, relationships, lifecycle,
persistent state, and command taxonomy.

Compare the model communicated by commands, help, documentation,
and output against:

- User goals and domain vocabulary.
- Established conventions of comparable tools.
- The intended application model.
- The actual relationships between commands and their effects.

Identify unnecessary concepts, inconsistent terminology, overloaded
actions, artificial distinctions, hidden modes, and implementation
details leaking into the public interface.

For command hierarchies with substantial friction, propose an
alternative command tree. Demonstrate its advantages through
representative workflows.

### 3. Walk realistic workflows

Walk every inventoried workflow using Norman's action cycle.

For goal, plan, specify, and perform, record:

- What the user wants to accomplish.
- What the user must know or infer.
- Where the interface supplies that knowledge.
- The command sequence and prerequisites.
- Friction, ambiguity, and execution gaps.

For perceive, interpret, and compare, record:

- What feedback the user receives.
- What the feedback actually establishes.
- Whether it distinguishes execution from achievement of the goal.
- How the user determines the next action or recovers from failure.

Include applicable first-use, frequent, advanced, unattended,
exceptional, and recovery paths.

Include representative human inspection, shell composition, and
structured-data consumption workflows for data-producing commands.

Use concrete transcripts. Count invocations, required decisions,
repeated inputs, and unnecessary setup where these expose meaningful
differences between designs.

In implementation mode, start with entry documentation and help
before consulting source where feasible. Record forced source reads
as discoverability findings.

### 4. Audit grammar and consistency

Construct a matrix of related command families, actions, arguments,
flags, selectors, defaults, units, and output modes.

Identify:

- Equivalent actions expressed through different grammar.
- Identical terminology with conflicting meanings.
- Ambiguous positional arguments or target selection.
- Inconsistent flag placement, scope, and defaults.
- Inconsistent output format selection, field selection, header
  suppression, or quiet-mode behavior.
- Command nesting or mandatory setup without workflow value.
- Unnecessary aliases, modes, or concepts.
- Domain notation that imposes avoidable translation or memorization.
- Extensions that would collide with existing command interpretation.

Test guessability by predicting an unfamiliar command from equivalent
known commands, then comparing the prediction to the actual grammar.
Record this as an agent-led heuristic rather than demonstrated human
usability.

For each proposed correction, show the current and recommended
invocations and explain the improvement.

### 5. Audit process-boundary contracts

For every applicable contract, record expected behavior and observed
or proposed behavior.

| Contract | Probe |
| --- | --- |
| Arguments | Missing, malformed, ambiguous, conflicting, and boundary values |
| Help | Root, subcommands, missing arguments, examples, typo recovery |
| Input | Files, stdin, EOF, paths, quoting, malformed records |
| Stream separation | Stdout results; stderr diagnostics, progress, and prompts |
| Human output | Readability, information hierarchy, units, meaningful precision |
| Grep-ability | Line-oriented records, predictable fields, absence of presentation artifacts |
| Shell composition | grep, awk, sed, cut, sort, uniq, head, tail, xargs, pipelines, redirection |
| Format selection | Appropriate supported formats, consistent flags, unsupported formats |
| Structured output | JSON validity, schema, types, precision, nullability, escaping |
| Tabular output | CSV/TSV headers, delimiters, quoting, embedded newlines, field consistency |
| Streaming output | JSON Lines, incremental delivery, buffering, backpressure, bounded memory |
| Output fidelity | Equivalent result semantics across supported formats |
| Output stability | Documented schemas, ordering guarantees, locale independence |
| Output filtering | Field selection, header suppression, identifier-only output |
| Partial output | Interrupted streams, truncation, failure reporting, exit status |
| Binary output | Byte preservation, absence of incidental text |
| Status | Success, failure, negative observations, cancellation |
| Configuration | Precedence, defaults, missing and invalid configuration |
| Context | Target resolution, ambiguity, stale context, explicit overrides |
| Interactivity | TTY and non-TTY input, prompts, unattended execution |
| Presentation | Independent stream capabilities, color, width, paging |
| Performance | Startup, help latency, long-running operation feedback |
| Lifecycle | Interruption, broken pipes, cleanup, repeated invocation |
| Persistence | Existing outputs, concurrent access, interrupted writes |
| Security | Secrets, privileges, unexpected writes or communication |
| Portability | Supported operating systems, shells, terminals, paths |
| Compatibility | Published syntax, behavior, formats, and persisted data |

In implementation mode, exercise the actual binary with disposable
fixtures. Capture commands, input, stdout, stderr, status, and side
effects separately. Use PTY-backed execution for terminal-sensitive
behavior and ordinary pipes or redirection for non-terminal behavior.

Capture raw output bytes when testing binary integrity, ANSI escape
handling, delimiters, encoding, or other byte-level contracts.

Measure consequential delays against the intended operating context.
Use deterministic synchronization and explicit readiness. Treat sleeps
used for synchronization and flaky probes as verification deficiencies;
identify application design causes where applicable.

Group equivalent probes only when their rules and expected outcomes
are equivalent.

### 6. Verify output composition

For every inventoried data-producing command, account for the output
expectations under `cli-design` *Composition and output formats*.

Evaluate whether the supported formats serve the result structure and
demonstrated workflows. Missing useful formats are findings; formats
without demonstrated value are candidates for deletion.

In implementation mode, execute representative pipelines with
independent consumers.

#### Grep-friendly text

- Filter and count records using `grep` and standard Unix tools.
- Extract, sort, deduplicate, and aggregate fields from line-oriented
  output.
- Exercise identifier-only output, header suppression, and field
  selection where supported.
- Exercise `xargs` or an equivalent argument consumer where relevant.
  Verify spaces and arbitrary filenames using the documented safe
  representation.
- Verify that line wrapping, decorative borders, ANSI escapes,
  pagination, truncation, and incidental messages cannot contaminate
  explicit plain output.
- Verify that embedded delimiters and newlines cannot silently corrupt
  documented record boundaries.
- Distinguish incidental parseability of human text from documented,
  stable plain-output contracts.

#### Structured and tabular formats

- Parse JSON and JSON Lines with an independent parser or `jq`.
- Parse CSV and TSV with an independent format-aware parser.
- Check documented field names, types, nullability, units, precision,
  ordering, and encoding.
- Verify escaping with spaces, quotes, delimiters, Unicode, and
  embedded newlines.
- Compare semantic results across supported formats, accounting for
  documented projection and presentation differences.
- Check how nested structures map to tabular representations.
  Identify silent loss, misleading flattening, and ambiguous values.
- Verify machine formats under different terminal widths, locales,
  color settings, and verbosity settings.
- Verify the separation of structured results from diagnostics and
  progress messages.

#### Streaming and process composition

- Exercise terminal output, pipes, and file redirection separately.
- Exercise empty, single-record, multi-record, large, interrupted,
  and failed result sets where applicable.
- Exercise malformed inputs or problematic field values that could
  corrupt output.
- Verify incremental delivery and bounded memory for large or
  unbounded results where required.
- Exercise slow downstream consumers and backpressure.
- Exercise early downstream termination through `head` or an
  equivalent consumer.
- Verify cancellation, flushing, partial-result semantics, diagnostics,
  and process exit status.
- Verify that formatting options affect representation alone.

For design-mode audits, specify equivalent proposed transcripts and
expected contracts. Mark runtime properties unverified.

Record commands, expected results, actual results, and exit statuses.
For pipelines, capture relevant producer and consumer statuses rather
than relying solely on the shell's final pipeline status.

Reuse existing acceptance-test or dogfood evidence where it covers the
same contract.

### 7. Audit safeguards and recovery

For consequential operations, enumerate applicable targets,
prerequisites, failure points, and observable states.

Evaluate likely mistakes, slips, misinterpretations, unsafe defaults,
and accidental repetition.

Check:

- Target and scope visibility.
- Validation before side effects.
- Preview and confirmation mechanisms.
- Fidelity of dry-run behavior.
- Protection of existing data.
- Cancellation and bounded cleanup.
- Partial completion and retained artifacts.
- Recovery after abnormal termination.
- Retry and repetition semantics.
- Accurate distinction between observed results and inferred outcomes.
- Whether scripts and downstream consumers can reliably detect
  incomplete or failed operations.

Identify the design conditions that permit mistakes rather than
attributing failures to user carelessness.

### 8. Sweep design rules and CLIG

For every workflow, account for each numbered design rule in
`cli-design` through a coverage matrix.

Also account for every guideline in the CLIG *Guidelines* sections:

- The Basics
- Help
- Documentation
- Output
- Errors
- Arguments and flags
- Interactivity
- Subcommands
- Robustness
- Future-proofing
- Signals and control characters
- Configuration
- Environment variables
- Naming
- Distribution
- Analytics

Use the current source rather than treating this section list as a
fixed inventory of individual guidelines.

Reuse evidence from earlier steps. Apply product-wide guidelines at
product scope rather than duplicating them across workflows.

Record each applicable rule or guideline as:

- Pass.
- Finding.
- Justified deviation.
- Inapplicable, with reason.
- Unverified, with reason.

For design-mode passes, distinguish a fully specified design contract
from verified runtime behavior.

Group related guidelines only when their individual dispositions
remain traceable.

Distinguish interoperability requirements from preferences and
conditional recommendations. Evaluate deviations by their effect on
users and workflows.

### 9. Evaluate alternatives

For findings involving command structure, state, workflow composition,
output contracts, or conceptual integrity, consider the smallest
coherent alternatives.

Compare alternatives through realistic transcripts against:

- Discoverability and guessability.
- Knowledge and setup required.
- Frequent-task efficiency.
- Consistency across workflows.
- Grep-ability and shell composition.
- Structured data consumption.
- Safety and recovery.
- Compatibility cost.
- Implementation and maintenance complexity.

Apply the deletion test: identify commands, flags, modes, output
variants, abstractions, and persistent state that can be removed
without sacrificing a demonstrated user need.

Evaluate whether standard shell tools and established data formats
can satisfy workflows currently requiring custom filters, scripting
languages, or specialized subcommands.

Prefer a coherent replacement over accumulating aliases and special
cases when compatibility commitments permit it.

Recommend changes in leverage order. Distinguish foundational design
changes from incremental polish.

### 10. Verify findings

Reproduce findings against the intended executable where available.
Capture the smallest representative reproduction.

For design-only findings, identify the exact specification or
transcript supporting the finding and distinguish predicted
consequences from observed failures.

Record representative-user evidence separately from agent walkthroughs.
Identify where human validation, real hardware, or supported platform
execution remains outstanding.

## Report

Include:

1. Context: target, revision or proposal version, date, scope, mode,
   existing consumers, and execution environment.
2. Public-surface inventory and affected workflows.
3. Conceptual model and command taxonomy.
4. Workflow transcripts and action-cycle findings.
5. Grammar and consistency matrix.
6. Process-boundary and safeguard coverage.
7. Output-format and composition coverage.
8. Design-rule and CLIG coverage.
9. Severity-ranked findings.
10. Recommended command grammar and representative transcripts
    where structural changes warrant them.
11. Unverified checks, assumptions, and validation gaps.
12. Re-evaluation delta, when applicable.

Each finding includes:

- Severity: blocker, high, medium, or low.
- Lens: model, workflow, grammar, discovery, composition, output,
  feedback, safety, compatibility, accessibility, or operational
  simplicity.
- Applicable design rule or guideline.
- Affected workflows and public contract.
- Expected and actual or proposed behavior.
- User impact and supporting evidence.
- Recommended correction, with example commands where applicable.
- Compatibility implications.
- Verification status.

Severity reflects consequences, not the reviewer's aesthetic preference:

- **Blocker:** Essential workflow impossible, unacceptable safety risk,
  or materially misleading outcome.
- **High:** Major workflow friction, recurring ambiguity, significant
  interoperability failure, unreliable machine output, or pervasive
  conceptual inconsistency.
- **Medium:** Meaningful but localized friction, inconsistency, or
  recoverable contract deficiency.
- **Low:** Minor discoverability, efficiency, or presentation issue.

Use these evidence classifications:

- **Observed:** Reproduced against the real executable.
- **Design-derived:** Supported by the proposed contract or documented
  grammar; runtime effect remains unverified.
- **Code-derived:** Supported by source inspection; runtime effect
  remains unverified.
- **Hypothesis:** Predicted user friction requiring further validation.

Prioritize findings by impact, frequency, breadth, and leverage.
Consolidate repeated symptoms under their shared design cause.

## Done criterion

Done when:

1. Every inventoried workflow has an action-cycle walkthrough and
   representative transcript.
2. Every affected command and shared contract is represented in the
   grammar and process-boundary coverage.
3. Every inventoried data-producing command has output-format and
   composition coverage, including grep-ability, structured formats,
   and supported format semantics. Unsupported or unavailable
   capabilities have a traceable disposition.
4. Every numbered `cli-design` rule and every CLIG guideline has a
   traceable disposition at its applicable scope.
5. Every consequential operation has applicable safeguard and
   recovery coverage.
6. Every finding has severity, evidence, impact, and a concrete
   recommendation.
7. Every significant structural recommendation includes representative
   before-and-after workflows and compatibility implications.
8. Every unavailable execution, platform, hardware, or human-validation
   check has an explicit unverified status and reason.
9. The chat reply gives the report path, findings count by severity,
   highest-leverage recommendations, and unverified coverage.

## Self-check

1. Reconcile the inventory with specs, help, documentation, parser
   definitions, and acceptance tests. Every in-scope surface has
   coverage or an explicit unverified status.
2. Compare every workflow against the action-cycle walkthrough and
   transcripts. Every step and outcome is accounted for.
3. Match applicable contracts against the process-boundary matrix.
   Every claimed runtime result has observed evidence.
4. Match every data-producing command and supported output format
   against the composition coverage. Inspect independent parser
   results, pipeline results, stream separation, and exit statuses.
5. Compare `cli-design` rules and CLIG guidelines against their
   coverage matrices. Every item has a traceable disposition.
6. Check each structural recommendation against its workflow
   transcripts and compatibility obligations.
7. Apply the deletion test to proposed additions as well as the
   existing interface. Every addition serves a demonstrated need.
8. Reconcile severity totals, evidence classifications, unresolved
   findings, and verification gaps with the final report.
