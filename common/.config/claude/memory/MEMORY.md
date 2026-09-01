# Global memory store — INERT

This store is not loaded. The harness points memory at the per-project store
`~/.claude/projects/<slug>/memory/` and injects only that MEMORY.md. Verified
2026-08-31: a dangling link here (`feedback_version_bumping.md`, never created)
survived from March unnoticed, and nothing here ever reached a session.

Cross-project rules belong in `CLAUDE.md` / `RTK.md` (loaded every session) or,
when machine-enforceable, in `settings.json` — not here. Leave the directory in
place; `~/.claude/memory` symlinks to it.
