---
name: commit
description: MUST be used for every git commit. Formats Conventional Commit messages, checks for breaking changes, and stages files atomically.
---

Message format: Conventional Commits v1.0.0 (`<type>(<scope>): <description>`).

- One logical change per commit; split if needed.
- Add a scope when one is easy to identify.
- Body only for non-obvious why/tradeoffs — keep it brief; the diff documents itself.
- Assess breaking-change impact every commit; if breaking, mark with `!` AND a `BREAKING CHANGE:` footer. Pre-1.0.0, breaking changes bump MINOR, not MAJOR.

Stage atomically — other agents may edit files in parallel. Commit only files you touched, each path explicit:

```sh
# tracked files
git commit -m "<message>" -- path/to/file1 path/to/file2

# brand-new files
git restore --staged :/ && git add "path/to/file1" "path/to/file2" && git commit -m "<message>" -- path/to/file1 path/to/file2
```
