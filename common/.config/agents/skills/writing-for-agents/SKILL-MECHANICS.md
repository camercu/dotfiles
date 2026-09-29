# Skill mechanics

Read when the doc is a skill: creating one, editing its frontmatter, or adding
bundled files.

## Start from real uses

Before writing, collect concrete requests the skill must serve, with the user's
literal phrasings (ask, or propose and confirm). Each request → what would get
rewritten or rediscovered on every run → that becomes a bundled file (below).
Phrasings become the description's triggers.

## Frontmatter

- `name`: kebab-case, equal to the directory name. Harness lists the skill by
  directory; other skills and AGENTS.md call it by name. Mismatch → one side
  points at nothing.
- `description` = **trigger cues only.** Only `name` + `description` are in
  context when the agent decides to invoke; the body loads after. So the
  description says *when*, never *what*:
  - Open "Use when …": situations, file types, literal user phrasings.
  - Name enough of the object to disambiguate a cue ("Use when reviewing a test
    suite"). No feature list, how-it-works, or output format.
  - Name the non-trigger when a neighbour skill would steal the invocation:
    "Not for X; use `other-skill`."
  - Front-load the leading word.
  - One trigger per branch. Synonyms naming one branch = one trigger; collapse.
  - Route only to model-invocable skills. A `disable-model-invocation` skill is
    reachable by the human alone; name it as `/skill-name` for the human.
  - Body section "When to use this skill" = dead weight: body loads only after
    triggering. Every cue goes in `description`.
- Other keys only when needed, e.g. `disable-model-invocation`, `argument-hint`,
  `context: fork` + `agent` + `model` (run in a subagent). Allowed keys and
  limits: the validator (*Validate*).

## Body

- Opens with `## Overview`: what the skill does in 1–3 sentences, plus what it
  deliberately leaves out. Description carries no *what*, so a reader landing
  cold learns the job here. Body ≤25 lines: skip Overview; it would be as long
  as the body.
- Under 500 lines. Nearing it → disclose into bundled files.

## Degrees of freedom

Match specificity to fragility:

- Many valid approaches, judgement-driven → prose rules.
- Preferred pattern, some variation → pseudocode or a parameterized script.
- Fragile, order-critical, or must be identical every run → a script with few
  parameters. Narrow bridge gets guardrails; open field gets a direction.

## Bundled files

Name each from SKILL.md with the condition for reading it. Keep every file one
link deep from SKILL.md; nested pointers get missed.

- `scripts/` — code rewritten every run, or needing deterministic output. Agent
  runs it without loading it. Test every script by running it before commit.
- `references/` (or files beside SKILL.md) — loaded on demand. Split by variant
  or domain (`aws.md`, `gcp.md`) so one branch loads one file. File >100 lines
  → table of contents at top. Very large → give grep patterns in SKILL.md.
- `assets/` — files copied into output (templates, boilerplate), never read
  into context.

Skill dir holds only what the agent needs to do the job. README, CHANGELOG,
install guide → human docs about the skill; keep them outside it.

## Invocation

- **Model-invoked** (default): agent reaches it alone; other skills can invoke
  it. Description costs context load every turn.
- **User-invoked** (frontmatter `disable-model-invocation: true`): description
  stays out of agent context; human must remember the skill. Write the
  description for the human; drop trigger phrasing.

Pick model-invoked when an agent must reach it unprompted or another skill
depends on it. Else user-invoked.

Split one skill into two by invocation only when a distinct leading word should
trigger each part on its own, and the extra always-loaded description pays.

## Router skill

Many user-invoked skills → one user-invoked router naming each and when to
reach for it. Human remembers one name. Router guides the human; agent cannot
invoke the skills it names.

## Validate

Run after every skill edit. Passes when each line ends `Skill is valid!`:

```sh
~/.config/agents/skills/writing-for-agents/scripts/validate_skill.py <skill-dir>...
```

Checks frontmatter keys, name = directory,
trigger cue in description, and Overview rule.

## Iterate from use

After a real run, note where the agent guessed, stalled, or skipped a step;
fix that spot in SKILL.md or a bundled file; run again.
