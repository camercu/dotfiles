# Skill mechanics

Read when the doc is a skill. Frontmatter and description rules: `skill-creator`
skill, *Frontmatter*. This file adds what it lacks.

## Description = pointer

`description` is a context pointer, always loaded. On top of skill-creator's
trigger-cue rules:

- Front-load the leading word.
- One trigger per branch. Synonyms naming one branch = one trigger; collapse.
- Route only to model-invocable skills. A `disable-model-invocation` skill is
  reachable by the human alone; name it as `/skill-name` for the human.

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
