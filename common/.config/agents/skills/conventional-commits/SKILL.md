---
name: commit
description: MUST be used for every git commit. Formats Conventional Commit messages, checks for breaking changes, and stages files atomically.
---

If you made more than one logical change, break up multiple logical changes into separate commits.

Keep commits atomic: commit only the files you touched and list each path
explicitly. This is because other agents or the user may be editing files in
parallel with you.

For tracked files, run:

```sh
git commit -m "<scoped message>" -- path/to/file1 path/to/file2
```

For brand-new files, run:

```sh
git restore --staged :/ && git add "path/to/file1" "path/to/file2" && git commit -m "<scoped message>" -- path/to/file1 path/to/file2
```

Follow the [convention commit](./references/conventional-commits.md) format
specification for all commit messages.
