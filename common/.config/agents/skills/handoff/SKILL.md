---
name: handoff
description: Use when user types /handoff or says "hand off", "handoff doc", "pass this to another session/agent" — work must travel to another harness, another repo, a colleague, or a forked parallel agent. Not for staying put in the same session; /compact covers that.
argument-hint: "what next session for?"
disable-model-invocation: true
---

# Handoff

## Overview

One markdown file. Fresh agent reads it cold, continues work. Buys
**portability**, not compression.

## When

Work must *travel*:

| Situation | Why file |
| --- | --- |
| Harness swap (Claude → Codex) | New harness can't see old context |
| Different dir / repo | Prototype dir = common case |
| Send to colleague | Needs something readable |
| Fork side task mid-phase | You keep session; second agent takes fork |

Nothing travels → `/compact` (intent survives) or `/clear` (nothing survives).
Handoff = *ability to move* survives. Fork case = the one people skip: stay in
session, hand copy of context to parallel agent, get answer back, reference it.

## Write

- Save to OS temp dir. **Never workspace** — transit doc, not artifact.
- Print absolute path back to user as last line.
- Never duplicate settled artifacts. Specs, plans, ADRs, issues, commits, diffs
  → path or URL only. Copies drift.
- Args = what next session for. Tailor; keep reasoning bearing on *that*.
- Redact keys, tokens, passwords, PII.
- **Unverified stays labelled unverified.** Next agent treats doc as contract,
  won't re-check. "X not built" / "Y done" only if this session actually
  checked. Else: "assumed, unverified". Belief written as fact = false premise
  for everything downstream.

## Shape

- **Goal** — what next session must achieve (from args)
- **State** — done / in flight / next
- **Why** — decisions + reasons, esp. ones bearing on goal
- **Refs** — paths + URLs, no copied text
- **Unverified** — claims never checked
- **Suggested skills** — names next agent should call Skill tool for

## Hand over

Point next agent at path: `read <abs path>, then continue`.

Never paste summary into `claude "<summary>"` — backticks and `$(...)`
interpolate, failure is silent truncation not error, agent starts on quietly
incomplete brief.

## Durability

Temp dies on reboot; some harnesses clear it between sessions. Next session
>1h away or under different harness → copy file somewhere durable now. Same
for everything doc points at — refs into temp = refs next agent can't follow.

## Done when

- Doc small fraction of conversation; artifacts appear as paths, not text
- Readable cold, original session closed
- Fresh agent works instead of asking you to re-explain
- Fork case: your session still sitting there untouched
- Suggested-skills names skill you'd have reached for yourself
- No key, token, password anywhere in it
