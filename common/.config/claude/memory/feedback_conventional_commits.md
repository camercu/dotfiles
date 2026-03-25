---
name: Use conventional-commits skill
description: Always use the conventional-commits skill when committing, never commit manually
type: feedback
---

Always use the `/conventional-commits` skill when the user asks to commit changes.

**Why:** User preference for consistent commit workflow using the skill's formatting and process.

**How to apply:** Whenever the user says "commit", invoke the `conventional-commits` skill instead of running git commit manually. This applies to all projects globally.
