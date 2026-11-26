---
name: cli-design
description: Use when designing or changing a command-line interface, command hierarchy, subcommands, arguments, flags, help, output formats, exit codes, or shell workflows, or when asked to make a CLI more intuitive, ergonomic, composable, or scriptable. For CLI reviews, use cli-audit; for GUI or TUI interaction, use ux-design.
---

# CLI design

## Overview

Design around user goals, then build and verify the public CLI contract.
Specialize the interaction principles in `ux-design` for command-line
interfaces. Serve interactive users, shell pipelines, scripts, agents,
and other applications through one coherent conceptual model.
`tdd` drives implementation; `cli-audit` independently evaluates the design.

## Context

- Read project requirements, CLI design docs, entry documentation,
  argument definitions, workflow tests, and affected command help.
  Approved requirements define intent; released behavior defines
  existing compatibility obligations; running behavior establishes
  current facts.
- Read [ux-design](../ux-design/SKILL.md), specifically *Design rules*.
  Apply its general interaction principles and Norman's action cycle
  through the CLI-specific rules below. CLI conventions, process
  contracts, and shell interoperability govern their application.
  GUI/TUI-specific layout, focus, pointer, and rendering requirements
  apply only to interactive visual interfaces. Use `ux-design` for
  interactive visual components of a CLI when applicable.
- Read [Command Line Interface Guidelines](https://clig.dev/) (CLIG).
  Treat CLIG as the default CLI design baseline. Justify deviations
  through user needs, domain conventions, or interoperability
  requirements.
- When designing utility syntax, consult applicable
  [POSIX utility conventions](https://pubs.opengroup.org/onlinepubs/9799919799/basedefs/V1_chap12.html)
  and [GNU conventions](https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html).
- Inspect relevant domain tools and established CLIs solving comparable
  interaction problems. Prefer conventions users already know.
- Establish existing consumers and compatibility commitments.
  An unreleased interface without consumers can be redesigned without
  preserving obsolete commands.

## Plan

Record these headings in the change's spec or task file. Scale detail
to scope, novelty, and risk. Reuse approved decisions by reference;
mark inapplicable items with a reason.

1. **Users and workflows.** Identify interactive users, script authors,
   automation, and agents as applicable. List affected goals as verb
   phrases with prerequisites, expected results, and recovery paths.
   Include first-use, frequent, advanced, and unattended workflows.
   Cite existing evidence or user input; label assumptions and identify
   which need validation.

2. **Conceptual model.** Define user-facing objects, relationships,
   actions, and lifecycle in domain vocabulary. Identify what must be
   explicit, what may be inferred, and what state persists between
   invocations. Compare the model with available evidence of users'
   mental models and established domain conventions.

3. **Workflow transcripts.** Write complete shell transcripts showing
   how users accomplish each goal: discovery, invocation, representative
   output, next action, and verification. Include pipelines, structured
   data consumption, failures, and recovery where applicable.
   Design these before choosing the parser structure.

4. **Command grammar.** Derive the command hierarchy, argument roles,
   flags, selectors, units, defaults, and mutual exclusions from the
   transcripts. Compare equivalent operations across command families.
   Specify the smallest coherent grammar that supports the workflows.

5. **Execution and output contracts.** Specify input formats, output
   formats, schemas, stream ownership, exit status, configuration
   precedence, target resolution, side effects, interactivity,
   cancellation, and partial outcomes. Distinguish human presentation
   from machine-readable contracts. Define compatibility commitments.

6. **Discoverability.** Draft root and affected subcommand help.
   Include task-oriented examples, prerequisites, defaults, supported
   output formats, and actionable errors. Specify completions and
   documentation appropriate to the command surface.

7. **Design validation.** Walk every transcript through Norman's action
   cycle: goal, plan, specify, perform, perceive, interpret, compare.
   Identify what users must know, what cues the CLI supplies, and where
   execution or interpretation breaks down. Apply the design rules
   below and the applicable interaction principles from `ux-design`.
   Evaluate alternatives through concrete transcripts rather than
   abstract preferences. Identify likely slips, mistakes, mode errors,
   and recovery paths.

8. **Verification.** Define acceptance criteria and executable contract
   tests for every affected workflow. Cover applicable terminal and
   non-terminal contexts, output formats, shell composition, failure
   paths, accessibility, and compatibility requirements.

**Gate.** Invoke `cli-audit` in design mode for materially new or changed
interfaces. Present the proposed grammar, representative transcripts,
output contracts, compatibility decisions, safeguards, and unresolved
findings for approval. Build after approval. Minor changes within an
approved design may reuse that approval. Return to the gate when
implementation requires a material change to the public contract.

## Design rules

Apply every rule to affected workflows and the CLI as a whole.
Record justified exceptions.

The general interaction principles in `ux-design` govern usability;
the rules below specialize them for CLI interaction, composition,
and process contracts. Apply CLIG and established conventions to
resolve CLI-specific design decisions.

### 1. User intent and conceptual integrity

- Name commands after user goals and domain actions rather than
  internal modules, implementation techniques, or architecture.
- Use one canonical term for each concept and one meaning for each term.
- Apply consistent action, object, selector, and modifier vocabulary
  across related commands.
- Group commands by the mental model that best supports the workflows.
  Prefer consistency and discoverability over mechanically uniform
  verb-first or noun-first hierarchies.
- Preserve meaningful distinctions between operations with different
  effects, prerequisites, or outcomes.
- Make relationships between commands, operands, targets, and effects
  apparent through their grammar and terminology.
- Remove internal abstractions users would otherwise need to learn.

### 2. Workflow economy

- Minimize time and knowledge required to achieve the first useful result.
- Make the frequent, safe path concise. Give uncommon and consequential
  choices explicit names.
- Eliminate redundant setup, repeated input, unnecessary mode changes,
  and intermediate artifacts that serve no user purpose.
- Provide direct commands for frequent coherent workflows; retain
  composable primitives for workflows requiring flexibility.
- Keep standalone operations independent of project or session state
  unless that state is necessary to their semantics.
- Support batch operations, reusable configuration, and other
  accelerators when demonstrated workflows warrant them.
- Introduce sessions, REPLs, workflow languages, background services,
  and orchestration layers only when demonstrated workflows justify them.

### 3. Grammar and predictability

- Use an established argument parser. Derive help, validation, and
  completions from shared argument definitions where practical.
- Use memorable lowercase command names and descriptive long flags.
  Reserve short flags for frequent operations.
- Reserve positional arguments for obvious operands and conventional
  common patterns. Name otherwise ambiguous argument roles with flags.
- Give equivalent flags equivalent semantics across command families.
- Support conventional option termination (`--`) and option placement
  where compatible with the grammar.
- Prefer explicit stable aliases over arbitrary prefix matching.
- Make invalid combinations, missing prerequisites, and ambiguous
  interpretations actionable errors.
- Keep command-specific flags local; make genuinely shared options
  consistently available.
- Choose defaults appropriate to common, safe workflows.
- Make unfamiliar commands guessable from familiar commands through
  consistent grammar, vocabulary, and option semantics.

### 4. Domain notation and precision

- Use familiar domain units, identifiers, selectors, and range notation.
- Define accepted units, implicit units, conversions, precision,
  rounding, boundaries, and overflow behavior where applicable.
- Reuse parsers and semantics for equivalent inputs across commands.
- Accept useful human notation at the boundary; normalize to canonical
  typed values before execution.
- Display quantities with meaningful units and appropriate precision.
  Keep machine representations unambiguous and documented.
- Distinguish missing, unknown, unlimited, automatic, and zero values
  whenever they have different meanings.

### 5. Context and configuration

- Define how targets, sources, destinations, environments, projects,
  profiles, and configuration are resolved.
- Make consequential context visible before execution. Reject ambiguity
  rather than silently choosing a potentially incorrect target.
- Prefer explicit per-invocation overrides. Specify precedence among
  flags, environment, project, user, system configuration, and defaults.
- Provide inspection of effective configuration and its provenance when
  layered configuration materially affects behavior.
- Follow native platform configuration and filesystem conventions.
- Prefer reproducible invocations over hidden mutable context.
- Make persistent context inspectable, controllable, and resettable
  where applicable.
- Reuse selectors and action semantics across live and recorded sources
  wherever their capabilities genuinely overlap.
- Document environment variables, their precedence, and their effects.
  Respect established environment conventions where applicable.

### 6. Discovery and learning

- Make `-h`, `--help`, and `--version` behave conventionally.
- Provide useful guidance when required arguments or subcommands are
  missing; return a status consistent with whether work was requested
  and completed.
- Lead help with purpose, usage, common operations, and representative
  examples. Organize commands and options by user tasks.
- Favor recognition over recall: expose available actions, accepted
  values, prerequisites, defaults, and relevant context at the point
  where users need them.
- Disclose advanced options progressively without making them
  undiscoverable.
- Document accepted notation, side effects, output formats, and
  outcome semantics.
- Suggest likely corrections to invalid input without executing
  unintended actions.
- Provide contextual next-command guidance where a workflow naturally
  continues.
- Provide shell completions and installed documentation when warranted
  by the size and complexity of the command surface.
- Keep discovery commands fast and independent of unrelated hardware,
  credentials, network services, or project initialization.
- Include shell composition and structured-output examples in the
  documentation for data-producing commands.
- Verify examples through the public executable.

### 7. Composition and output formats

**Principle:** One semantic result, multiple renderers. Support human
inspection, Unix shell composition, and structured data consumption
without duplicating application behavior.

#### Streams

- Treat output as a public interface for humans, shell pipelines,
  scripts, agents, and other applications.
- Reserve stdout for primary results; send diagnostics, progress,
  prompts, and incidental messaging to stderr.
- Support stdin, stdout, files, and `-` stream notation where compatible
  with the data format and execution model.
- Preserve binary data byte-for-byte when stdout carries a binary
  payload.
- Support shell quoting, spaces in paths, Unicode, and filenames
  beginning with hyphens.
- Handle broken pipes appropriately, including consumers that
  intentionally terminate early. Define exit behavior consistently.

#### Grep-ability

- Make default text output grep-friendly wherever practical. Prefer
  one logical record per line, predictable field ordering, consistent
  delimiters, and recognizable field names.
- Preserve composition with standard Unix tools: `grep`, `awk`, `sed`,
  `cut`, `sort`, `uniq`, `head`, `tail`, and `xargs`.
- Keep record boundaries meaningful. Escape or encode embedded
  newlines and delimiters when necessary to preserve those boundaries.
- Provide `--plain` or an equivalent explicit format when human
  presentation interferes with shell composition.
- Plain output has no decorative borders, wrapping, truncation,
  ANSI escapes, pagination, or unrelated messages.
- Provide header suppression, identifier-only output, and field
  selection when demonstrated workflows benefit from them.
- For arbitrary filenames or identifiers containing line separators,
  provide an unambiguous representation or NUL-delimited output
  when shell composition warrants it.
- Document which text formats are stable contracts. Direct scripts
  requiring stronger guarantees to documented plain or structured
  formats.

Structured output supplements grep-friendly text rather than
replacing it. Users should be able to perform simple ad hoc processing
with ordinary shell tools without requiring a structured-data parser.

#### Format selection

Use one consistent format-selection grammar across commands. Prefer
`--format <format>` when multiple formats are supported. Conventional
shortcuts such as `--json` or `--plain` may supplement the canonical
grammar when justified by existing conventions or frequent use.

Choose formats according to result structure and demonstrated workflows:

| Format | Purpose |
| --- | --- |
| `text` | Readable, preferably grep-friendly human output |
| `plain` | Unadorned, predictable, line-oriented records |
| `table` | Human-readable tabular presentation |
| `json` | Structured objects and bounded collections |
| `jsonl` | Incremental structured records and unbounded streams |
| `csv` | Tabular data exchange and spreadsheet interoperability |
| `tsv` | Tabular data processing and shell composition |
| Native format | Domain-specific or binary data exchange |

Expected capabilities:

- Grep-friendly text wherever results naturally support line-oriented
  representation.
- JSON for meaningful structured results.
- JSON Lines for structured streaming results.
- CSV and TSV where tabular processing or exchange is valuable.
- Human-readable tables where they improve comprehension.
- Native formats for inherently binary or domain-specific artifacts.

Support the formats that serve the workflows. A single grep-friendly
text renderer may satisfy both `text` and `plain` requirements; introduce
distinct variants only when they provide distinct value.

Evaluate data-producing commands against these expectations and record
the rationale for unsupported formats.

#### Structured output contracts

- Document machine-readable schemas, field names, types, units,
  precision, nullability, encoding, ordering guarantees, and
  compatibility policy.
- Use established serializers and escaping conventions. Preserve
  delimiters, quotes, whitespace, Unicode, and embedded newlines
  without corrupting records.
- Define CSV/TSV dialects, headers, quoting, and escaping.
- Define how nested or heterogeneous data maps to tabular formats.
  Reject unsupported representations rather than silently discarding
  meaningful data.
- Preserve the distinction between empty results, missing fields,
  null values, unknown values, and zero.
- Keep machine output independent of terminal width, locale, color,
  verbosity, progress reporting, and interactive presentation settings.
- Keep explicit machine formats stable whether stdout is attached to
  a terminal, file, or pipe.
- Preserve full semantic precision in machine formats. Apply rounding
  and abbreviations only to presentation where appropriate.
- Derive output variants from a shared semantic result model.
  Formatting and field projection affect representation, not application
  behavior or the underlying result.
- Provide documented structured error output when automation requires
  it. Keep errors separate from the primary result stream unless the
  result schema explicitly represents per-record failures.

#### Streaming and composition

- Stream large or unbounded results incrementally with bounded memory.
  Define buffering, flushing, backpressure, and partial-output behavior.
- Prefer JSON Lines over a single growing JSON document for unbounded
  structured streams.
- Define empty-result and interrupted-stream representations for every
  supported format.
- Preserve the validity of completed streaming records on interruption
  where practical. Report incomplete operations through the documented
  exit-status and diagnostic contracts.
- Keep data records available to downstream consumers without
  unnecessary buffering or waiting for unrelated work to complete.
- Provide `--quiet` (`-q`) where useful to suppress nonessential
  messaging while preserving requested result data and consequential
  diagnostics.
- Prefer standard formats and ordinary process composition over custom
  pipeline, filtering, or expression languages unless domain
  requirements justify them.

### 8. Feedback and outcome semantics

- Provide concise, meaningful interactive feedback proportionate to
  the operation's duration, complexity, and consequences.
- Apply the feedback principles and response-time guidance in
  `ux-design` to interactive CLI operations. Preserve machine-output
  contracts when presenting feedback.
- Distinguish request acceptance, operation completion, and verified
  achievement of the user's goal.
- Report empty, partial, interrupted, stale, uncertain, and failed
  results accurately wherever applicable.
- Expose consequential loss, truncation, coverage limits, uncertainty,
  and provenance.
- Use exit status to represent the documented process outcome.
  Define how negative observations differ from execution failures.
- Preserve conventional exit-status semantics where they apply.
- Give expensive operations meaningful progress, elapsed time, and
  estimates when those estimates can be supported.
- Make errors identify the failing operation, relevant context, cause
  when known, remaining state, and actionable recovery.
- Show consequential state changes and provide a way to inspect
  persistent state when it is otherwise hidden.
- Make automation observable and controllable. Communicate its actual
  capabilities, limitations, and side effects.

### 9. Interactivity and accessibility

- Provide a complete non-interactive execution path for every
  operation intended for automation.
- Determine stdin, stdout, and stderr terminal capabilities independently.
- Prompt only when interaction is possible and appropriate. Provide
  explicit arguments and confirmation mechanisms for unattended use.
- Adapt human presentation to terminal width and capabilities while
  preserving explicit machine-output contracts.
- Establish information hierarchy through meaningful ordering,
  alignment, headings, spacing, and concise labels.
- Respect `NO_COLOR`, terminal capabilities, and explicit presentation
  options; convey essential information without relying on color alone.
- Enable paging and animated progress only in appropriate terminal
  contexts. Provide explicit overrides.
- Keep redirected output and CI logs readable and free of terminal
  control noise.
- Make prompts, diagnostics, and status messages understandable without
  visual-only cues.
- Provide a non-interactive alternative to interactive selection
  whenever the same operation is suitable for scripting.
- Ensure interactive prompts support predictable keyboard operation,
  cancellation, correction, and accessible alternatives.
- For interactive visual components, apply `ux-design` and its
  applicable accessibility requirements. Verify actual terminal and
  assistive technology behavior; document platform limitations.

### 10. Safety and recovery

- Make externally visible side effects explicit, especially writes,
  transmission, network access, privilege changes, and destructive
  actions.
- Validate prerequisites before irreversible work.
- Prefer error prevention, safe defaults, reversible actions, and
  preservation of user work over error messages alone.
- Match confirmation, preview, and interlock strength to the
  operation's potential consequences.
- Derive dry-run and execution behavior from the same validated plan
  where practical. State effects or outcomes that cannot be predicted.
- Protect existing data. Use atomic replacement or transactional
  mechanisms where supported and warranted.
- Define behavior for retries, repeated invocation, concurrent writers,
  interrupted writes, and incomplete operations.
- Prefer idempotent operations; where repetition has meaningful
  effects, define deduplication, compensation, at-most-once behavior,
  or explicit repeat semantics as appropriate.
- Respond promptly to cancellation. Bound cleanup and define escalation,
  retained artifacts, and recovery behavior.
- Support pause, resume, and reversal where meaningful and safe.
- Expect abnormal termination and recover safely on subsequent
  invocation.
- Accept secrets through appropriate protected channels and redact
  them from diagnostics. Require informed consent for telemetry and
  unexpected external communication.
- Investigate the design causes of user errors. Correct ambiguous
  grammar, misleading feedback, unsafe defaults, and hidden state
  rather than relying solely on warnings or documentation.

### 11. Compatibility and evolution

- Treat documented commands, flags, defaults, statuses, and structured
  output as public contracts.
- Establish compatibility scope according to actual consumer
  commitments.
- Prefer additive evolution and explicit, documented deprecation for
  established interfaces.
- Define compatibility requirements for structured output and persisted
  data. Introduce schema versions where consumers need them.
- Preserve extension space in the command grammar.
- Share argument definitions, documentation generation, and behavioral
  contracts where this prevents drift.
- Preserve semantic consistency across CLI, GUI, TUI, API, and MCP
  frontends where they expose equivalent application operations.

### 12. Operational simplicity

- Keep parsing, validation, application decisions, execution, and
  rendering appropriately separated.
- Implement domain behavior in reusable application or library modules;
  keep CLI-specific translation and presentation at the process boundary.
- Use types to represent valid command requests and resolved context
  where practical.
- Derive help, availability, validation, and execution constraints from
  shared rules where practical. Recheck prerequisites at execution
  when state can change.
- Share behavior across frontends rather than invoking or parsing the
  CLI internally unless process isolation is an actual requirement.
- Prefer the smallest architecture that supports demonstrated workflows.
- Keep startup responsive and unnecessary initialization out of
  lightweight commands.
- Prefer native distribution mechanisms and straightforward
  installation and removal.
- Apply the deletion test to commands, flags, modes, output variants,
  persistent state, and architectural layers. Each addition must serve
  a demonstrated workflow or contract.

## Build

- Invoke `tdd` for each behavioral slice using the planned acceptance
  criteria.
- Derive parsers, help, and completions from shared definitions where
  supported by the selected tooling.
- Translate validated input into application operations. Keep terminal
  rendering, process exit status, and operating-system I/O at the edge.
- Represent user-observable outcomes and valid command states
  explicitly. Derive output, diagnostics, and exit status from the
  actual outcome.
- Implement output formats as renderers over shared semantic results
  or result streams. Use established serializers.
- Test domain decisions through their public behavioral interfaces.
  Test process-boundary contracts through the actual executable.
- Use independent parsers to verify structured output rather than
  relying on the implementation's own serialization round trips alone.
- Use deterministic fixtures, explicit readiness, injected clocks and
  randomness, and controllable infrastructure for process tests.
  Treat sleeps used for synchronization, settling waits, and flaky
  synchronization as design defects requiring architectural correction.

## Verify

1. Build the intended revision and run acceptance tests for every
   affected workflow.
2. Execute the approved transcripts and affected documentation examples
   against the real binary.
3. Exercise applicable process-boundary contracts: arguments, help,
   input, stdout, stderr, exit status, configuration, terminal modes,
   cancellation, and recovery.
4. For every affected data-producing command, exercise each supported
   output format, representative shell pipelines, independent
   structured-data parsers, and empty and partial results.
5. Compare semantic results across supported output formats. Verify
   terminal, pipe, and file behavior, escaping, streaming, and early
   downstream termination where applicable. Capture relevant producer
   and consumer exit statuses independently.
6. Verify applicable accessibility requirements, supported platform
   behavior, and compatibility obligations using appropriate
   environments and fixtures.
7. Invoke `cli-audit` in implementation mode. Use a fresh reviewer for
   substantial changes. Reuse equivalent live evidence. Resolve
   findings, rerun affected checks, and re-audit.
8. For novel, risky, or uncertain interactions, observe representative
   users accomplishing realistic goals without revealing the command
   sequence. Record task completion, assistance, errors, and friction
   against planned success criteria. Revise the design from evidence.
   If users are unavailable, record human validation as outstanding;
   use the cognitive walkthrough and audit as interim evidence.

## Done criterion

Done when:

1. Every affected workflow has an approved design, transcript, and
   acceptance criteria, with all plan headings accounted for.
2. Every applicable CLI design rule, general interaction principle,
   and CLIG guideline has been applied or has a documented exception.
   Reuse the audit coverage rather than maintaining duplicate matrices.
3. Acceptance and executable contract tests pass for every affected
   workflow. Documentation examples match observed behavior.
4. Every affected data-producing command has a documented output
   contract. Grep-ability, format selection, supported serializers,
   semantic fidelity, and composition checks pass where applicable.
5. Every applicable verification item has observed evidence or an
   explicit unverified status with reason. Unverified release-critical
   checks require user acceptance before reporting done.
6. `cli-audit` has zero unresolved blocker or high findings unless
   explicitly accepted by the user. Apply the same rule to findings
   from accessibility and representative-user validation.
7. The report identifies the design, tests, audit, compatibility
   implications, skipped checks, and outstanding validation.
   Distinguish functional verification from demonstrated usability.

## Self-check

1. Reconcile changed commands, options, and output contracts with the
   approved workflow inventory. Every public change is accounted for.
2. Trace each affected workflow through Norman's action cycle and the
   applicable design rules in this skill and `ux-design`. Every gap
   is resolved or recorded with rationale and status.
3. Compare equivalent operations across command families. Every
   inconsistent term, flag, default, or behavior is resolved or justified.
4. Run affected transcripts and documentation examples against the
   intended binary. Every claimed result has observed evidence.
5. Check applicable process-boundary contracts independently of
   application-level behavior.
6. Exercise representative grep, shell pipeline, and structured-output
   workflows. Compare results across formats with independent consumers.
7. Compare final behavior against compatibility commitments,
   accessibility requirements, and consequential safeguards.
8. Apply the deletion test to the resulting interface. Every command,
   flag, mode, output variant, and persistent concept earns its keep.
9. Account for all audit findings, approvals, failed checks, skipped
   checks, and unverified human or platform validation.
