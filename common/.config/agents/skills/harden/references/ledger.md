# Ledger

Context window dies (compaction, `/clear`, session end); ledger survives.
Ledger holds run **state**; findings file holds **evidence**.

## Files

- `<repo>/.scratch/harden/LEDGER.md` — state.
- `<repo>/.scratch/harden/findings.md` — evidence, per
  `~/.config/agents/record-as-you-go.md`. Each delegated pass writes its own
  section or own file under `.scratch/harden/`, named in the ledger, so parallel
  agents never collide.

`.scratch/harden/` is working state; exclude rule: AGENTS.md *Working files*.

## Template

```markdown
# Harden ledger
Scope: <paths or "repo">  Range: <base>..<head>
Matrix: <command per line>
Last matrix run: <commit> <green|red: which command>
Authority docs: <paths or "working contract: README + API + tests">
Friction report: <path>
Findings files: <path per pass and round>
Position: step <n>, slice <id>, round <n>

## Slices
| id | status (pending/in-progress/done/declined) | commit subject |

## Passes (round <n>)
| pass | RAN / N/A / SKIPPED / polluted | agent | result or reason |

## Gates
| gate | options | user verdict |

## Decisions
- <decision> → <ADR path | commit sha>

## Sizing
- <right-size choice + why>
```

## Checkpoint

Update the ledger at: step change, slice commit, matrix run, pass row, gate
verdict. Checkpoint written = safe `/clear` point. Context heavy → suggest
`/clear` + re-invoke to the user.

## Resume

Ledger exists on invoke:

1. `git cat-file -e <sha>` for every recorded commit, and compare Scope with
   the user's request.
2. All match → continue at Position.
3. Any mismatch → report which, ask the user: resume, or start fresh (delete
   `.scratch/harden/`).
