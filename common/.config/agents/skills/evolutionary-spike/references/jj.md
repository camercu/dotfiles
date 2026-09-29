# jj: deleting spike branches

Colocated jj repo: `git branch -D spike/x` drops the ref, then jj's next import
sees the commits as unreachable and abandons them — including any `main`-line
commit that branch pointed at.

- Delete with `jj bookmark delete spike/x`.
- Used `git branch -D` anyway → check `jj log` right after.
- Commits abandoned → `jj op log`, then `jj op restore <op>`. Nothing is lost
  once noticed.
