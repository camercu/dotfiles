#!/usr/bin/env bash
# PreToolUse guard for `git push` (wired from .claude/settings.local.json).
#
# semantic-release lands `chore(release)` commits on the remote mid-session, so
# a push composed minutes earlier is rejected non-fast-forward. This fetches the
# upstream and, if it moved, rebases the local commits onto it. The release
# commits touch disjoint files (CHANGELOG/Cargo.*), so the replay is clean and
# the push then fast-forwards; a conflicting rebase is aborted and the push
# blocked (exit 2) for manual repair. Only local, unpushed commits are rebased —
# published history is never rewritten. Exit 0 lets the push proceed.
set -euo pipefail

cmd="$(jq -r '.tool_input.command // ""')"
grep -Eq '^(rtk +)?git( +-C +[^ ]+)? +push' <<<"$cmd" || exit 0

repo="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ -n "$repo" ] && cd "$repo"

# Upstream this branch tracks (e.g. origin/main). No upstream => nothing to
# reconcile; let git run the push (e.g. `push -u` establishes tracking).
upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)" || exit 0
[ -n "$upstream" ] || exit 0
remote="${upstream%%/*}"; branch="${upstream#*/}"

# Seam: tests drive real local remotes and leave this unset.
if [ -n "${LITMASK_GUARD_FETCH_CMD:-}" ]; then
  eval "$LITMASK_GUARD_FETCH_CMD" >/dev/null 2>&1 || { echo "guard-push: fetch failed." >&2; exit 2; }
elif ! git fetch "$remote" "$branch" >/dev/null 2>&1; then
  echo "guard-push: \`git fetch $remote $branch\` failed; resolve connectivity before pushing." >&2
  exit 2
fi

# Upstream already an ancestor of HEAD => local is ahead only; the push
# fast-forwards as-is.
if git merge-base --is-ancestor "$upstream" HEAD; then exit 0; fi

# Remote moved. Rebase local commits onto it; proceed only on a clean replay.
if git rebase "$upstream" >/dev/null 2>&1; then
  echo "guard-push: rebased local commits onto $upstream (remote moved); push will fast-forward." >&2
  exit 0
fi
git rebase --abort >/dev/null 2>&1 || true
echo "guard-push: $upstream moved and the rebase did not apply cleanly (not fast-forwardable). Rebase and resolve the conflict manually, then push." >&2
exit 2
