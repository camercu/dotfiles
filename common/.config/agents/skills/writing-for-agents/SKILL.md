---
name: writing-for-agents
description: Use when writing or editing any text an agent reads — a skill (including "make a skill", "write a skill for X", "update the skill"), AGENTS.md / CLAUDE.md, memory file, subagent or workflow prompt, task brief, spec an agent executes, or a doc reached by a pointer. Human-facing docs → `unslop`.
---

# Writing for agents

## Overview

Reader = agent. Knows everything general, nothing local. Explanation of general
knowledge = waste; precision about the local = the whole job. Default edit =
delete.

Aim: same *process* every run, not same output. Levers below make it
repeatable. Doc is a skill (new skill, frontmatter, bundled files, invocation):
read [`SKILL-MECHANICS.md`](SKILL-MECHANICS.md).

## Shape of a task-bearing doc

Any doc that asks for work (skill, brief, subagent prompt, spec step) carries
five parts. Omit a part only when it is empty for this task.

1. **Goal** — outcome + why, one or two lines. Why lets agent judge edge cases
   the doc never names. In a skill this is `## Overview` (`SKILL-MECHANICS.md`).
2. **Context** — where to look (next section). Pointers, not pasted content.
3. **Steps** — ordered actions, only where order matters. Else rules.
4. **Done criterion** — how agent knows it is finished (below).
5. **Self-check** — checks agent runs before it reports done (below).

Reference-only doc (review rules, style guide): parts 1, 2, 4, 5 still apply.
Done criterion = "every rule applied to every item".

## Context: tell agent where to look

Agent can find anything, but guesses what to find. Name it.

- **Point at source of truth.** Path + anchor: `src/auth.rs:120`, regex
  (`grep -n 'fn verify'`), command (`just --list`, `cargo metadata`), URL.
  Anchor survives edits better than line number; use line only for stable
  files.
- **Say when to read it.** Pointer = condition + target: "Touching the
  schema: read `docs/adr/0007-schema.md` first." Pointer's *wording* decides
  whether it fires. Must-read target behind vague wording = variance bug.
  Target every branch needs → inline it (see *Information hierarchy*). Target
  some branches need → sharpen pointer wording; inline only when sharpening
  fails.
- **Say what counts as authority** when sources conflict: spec > tests >
  code comments, or whatever holds here.
- **Cache only what lookup can't give.** Environment (`package.json`, config,
  `--help`, dir layout) = source of truth; restating it = stale cache.
  Write down what no file confesses: unwritten convention, reason behind a
  choice, gotcha, which of two similar things is live.
- **Subagent prompt:** it starts cold. Give paths, commit range, commands,
  prior findings it needs, and the files it should leave unread (ones that
  would prime it).

## Done criterion: checkable and exhaustive

Each step and the task as a whole end on a **done criterion**. Two properties:

- **Checkable.** Agent can tell done from not-done by observing something:
  command exit, test name passing, file exists, count reaches zero, every item
  in a named list handled. Vague bound ("understand the module", "clean up")
  invites **premature completion**: attention slides to being done.
- **Exhaustive.** Demand sets legwork. "Every caller of `parse_config` updated"
  forces a search; "update callers" does not. Name the set and its source:
  `rg -l 'parse_config\('` output, `git diff --name-only`, every row of table X.

Write it as "Done when …" with the evidence to show. Output contract belongs
here too: format, location, length, what to report.

Premature completion persists after sharpening, and criterion stays
irreducibly fuzzy → split the sequence across a real context boundary
(subagent, hand-off) so later steps stay out of view. Inline call hides
nothing.

## Self-check before done

Agent validates its own work before reporting. Write checks as concrete
actions with a pass condition, not "review your work".

- **Product checks** — does the output meet the done criterion? Run it: build,
  test, lint, render, execute the example, diff against expected. Observed
  result, not belief.
- **Process checks** — did the run follow the doc? Every step done or
  reported skipped with reason; every named skill actually invoked; every item
  in the exhaustive set accounted for; nothing claimed that wasn't run.
- **Honest report** — state what passed, what failed with output, what was
  skipped and why. Red stays red in the report.
- **Independent eye for judgement calls** — quality/correctness review of
  substantial work runs in a fresh agent; author context sees its own work as
  right.

Form: short numbered list of yes/no questions or commands with expected
result. Each check must be able to fail. Check that can't fail = no-op; cut.

## Positive directives

Tell agent what to do. Negation primes the banned behaviour: "don't mock the
DB" puts *mock the DB* in context, and the weak *don't* gets overrun. State
the target so the unwanted behaviour is never spoken.

| Negative | Positive |
|---|---|
| Don't write long comments. | Write one-line comments. |
| Don't stop early. | Done when every file in `git diff --name-only` has a test. |
| Never use `/tmp` in tests. | Tests write under `tempfile::tempdir()`. |
| Don't explain basics. | Write only what the repo can't tell the agent. |

Prohibition earns its place only as hard guardrail with no positive form
(irreversible action, security boundary). Then pair it with the target:
"Push only after user confirms; otherwise commit locally and report."

## Leading words

A **leading word** = compact concept the model already holds from pretraining
(*tracer bullet*, *red*, *tight loop*, *fog of war*). Repeat the token; define it
once. It gathers meaning across the doc and anchors behaviour in few
tokens. Also anchors invocation: same word in prompts, docs, and code → agent
links them and reaches the doc.

- Hunt restatements that collapse: "fast, deterministic, low-overhead" →
  *tight*; "a loop you trust fails on the bug" → loop goes *red*.
- Prefer existing words. Coined word recruits no priors; pay for it in
  definition tokens.
- Too-weak word = no-op (*be thorough* when agent is already thorough-ish).
  Fix with stronger word (*relentless*, *exhaustive*), not more sentences.
- One name per thing, everywhere. Three names teach three things.

## Information hierarchy

Two content types: **steps** (do, in order) and **reference** (consult on
demand). Place each on a ladder by how soon agent needs it:

1. In-file step.
2. In-file reference. Flat peer list (every rule of a review) is fine.
3. Disclosed reference — own file, reached by pointer, loaded when pointer
   fires.

Test: inline what every branch needs; disclose what only some branches reach.
Reference that belongs below buries the steps and makes following them a coin
flip. Keep a concept's definition, rules, and caveats under one heading
(co-location). **Sprawl** = too long even when every line is live; cure =
disclose and split by branch.

**Two loads.** *Context load* = always-loaded text (AGENTS.md line, skill
description) costing tokens and attention every turn; prune hardest there.
*Cognitive load* = human knowing which docs exist and when; spend it only
where human judgement matters.

Split a doc only when the cut pays: by sequence (later steps tempt rushing),
by invocation (distinct trigger, see `SKILL-MECHANICS.md`).

## Pruning

- **One source of truth** per meaning. Duplication costs maintenance, tokens,
  and inflates the meaning's rank. Point instead of copying.
- **Relevance.** Every line bears on the task today. Stale layers = sediment;
  delete when found.
- **No-ops.** Sentence the model obeys by default changes nothing. Test =
  behaviour vs default. Clear no-op → delete whole sentence. Unsure → run the
  doc on a real task without it and compare.
- **Rule over enumeration.** Name the rule ("every `pub fn`"), not the list
  that goes stale. Doc restates code facts: read
  `~/.config/agents/guard-ladders.md`, *Docs drift*.
- **Anecdote vs reason.** Keep a measurement or incident when it is the reason
  behind a rule the agent would otherwise bend. Cut it when the rule stands
  without it.

## Style

`→` fine for causality.

Every rule carries its reason: "Commit only when green — every commit on
`main` must build." CAPS only for a hard guardrail whose miss can't be undone
(push, delete, secrets), reason attached there too. Emphasis spread wide loses
its signal, and models over-apply it.

## Reviewing a doc

Output one line per finding, grouped by section of this skill:
`path:line — lever — problem → positive rewrite`. End with the self-check
results below, each PASS / FAIL + evidence.

## Done criterion

Doc being written or edited:

1. Each of the five parts is present, or is empty for this task.
2. Every pointer names a real target (path/regex/command resolves now) and a
   condition for reading it.
3. Every directive states target behaviour; each remaining prohibition is a
   hard guardrail paired with its positive form.
4. Self-check below passes on the doc.

## Self-check

Run before reporting done:

1. Resolve every path and run every command the doc names. Each resolves.
2. `rg -n -i "\b(don'?t|do not|must not|never|avoid)\b" <doc>` — each hit
   that directs the agent is a guardrail paired with a target; else rewrite it
   positive.
3. For each done criterion: name the observation that proves it. None →
   sharpen.
4. For each self-check the doc prescribes: describe one run where it fails. No
   such run → cut it.
5. For each sentence: would the agent do this anyway? Yes → delete. Unsure →
   see *No-ops*.
6. Meaning also stated in AGENTS.md, a pointed-to file, or another skill →
   replace with pointer.
7. Edit to existing doc: compare line count before/after. Grew → justify each
   added line or cut.
8. New skill, or new doc over ~50 lines → fresh agent executes a real task
   with it and reports where it guessed. Fix those spots.

Based on `mattpocock/skills` `skills/productivity/writing-for-agents`
(fetched 2026-09-28).
