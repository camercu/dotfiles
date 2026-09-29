---
name: conventional-commits
description: MUST be used for every git commit. Use when about to run git commit, or when user says "commit this", "/commit", or asks for a commit message.
---

# Conventional Commits

## Overview

Formats Conventional Commit messages, checks for breaking changes, stages files atomically.

Message format: Conventional Commits v1.0.0 (`<type>(<scope>): <description>`).

- One logical change per commit; split if needed.
- Add a scope when one is easy to identify.
- Subject: imperative ("add", not "added"), ≤50 chars when possible, 72 hard
  cap, no trailing period.
- Register: caveman lite + `unslop` patterns (AGENTS.md *Writing*).
- Body only for non-obvious why, tradeoffs, migration notes; the diff says
  what. Always a body for breaking changes, security fixes, data migrations,
  reverts: future debuggers need the why. Body states facts about the code, so
  "this commit", "I", "we", "now" add nothing.
- Assess breaking-change impact every commit; if breaking, mark with `!` AND a `BREAKING CHANGE:` footer. Pre-1.0.0, breaking changes bump MINOR, not MAJOR.
- Message ends at body or `BREAKING CHANGE:` footer. NEVER add co-authored-by footers (e.g. `Co-Authored-By:`) or any agent-attribution trailer.
- Subject-only commit: single `-m`:

```sh
git commit -m "feat(scope): subject" -- path/to/file1 path/to/file2
```

- Body needed → NEVER eyeball line length with multiple `-m` flags (commitlint `body-max-line-length` 100; manual guessing fails repeatedly). Feed `git commit -F` a process substitution that wraps the body with `fmt -w 72`. Tool wraps → no length failures. No temp file, no heredoc:

```sh
git commit -F <(echo "feat(scope): subject"; echo; \
  echo "Body prose, one blob, no manual breaks. Footer below, blank-separated." | fmt -w 72; \
  echo; echo "BREAKING CHANGE: details" | fmt -w 72) \
  -- path/to/file1 path/to/file2
```

- `fmt -w 72` = every line ≤72, well under 100. BSD `fmt` (macOS) keeps blank-line paragraph breaks → footer stays own paragraph. Drop the footer block when not breaking.
- Only miss: single token >100 chars (long URL/path) — `fmt` won't break one word. Rare; shorten or accept the flag.
- No embedded newlines in `-m`, no heredoc.

Stage atomically — other agents may edit files in parallel. Commit only files you touched, each path explicit:

```sh
# tracked files
git commit -m "<message>" -- path/to/file1 path/to/file2

# brand-new files
git restore --staged :/ && git add "path/to/file1" "path/to/file2" && git commit -m "<message>" -- path/to/file1 path/to/file2
```
