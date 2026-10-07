#!/usr/bin/env bash
# PreToolUse guard for `git push` and `jj git push` (wired from settings.json).
#
# semantic-release lands `chore(release)` commits on the remote mid-session, so
# a push composed minutes earlier is rejected non-fast-forward. This fetches the
# upstream and, if it moved, rebases the local commits onto it. The release
# commits touch disjoint files (CHANGELOG/Cargo.*), so the replay is clean and
# the push then fast-forwards; a conflicting rebase is aborted and the push
# blocked (exit 2) for manual repair. Only local, unpushed commits are rebased —
# published history is never rewritten. Exit 0 lets the push proceed.
#
# Two backends: plain `git push` (rtk-optional) reconciles with git; `jj push` /
# `jj git push` reconciles with jj-native commands (a `git rebase` inside a
# colocated jj repo would rewrite refs behind jj's back and strand the working
# copy). The jj path reconciles the `main` bookmark against `main@origin`.
set -euo pipefail

# Without jq the payload can't be read; exit 127 would be non-blocking and
# silently disarm the hook, so refuse instead.
command -v jq >/dev/null 2>&1 || { echo "guard-push: jq not installed; blocking every Bash call so the guard cannot be bypassed. Install jq." >&2; exit 2; }

cmd="$(jq -r '.tool_input.command // ""')"

if grep -Eq '^(rtk +)?git( +-C +[^ ]+)? +push' <<<"$cmd"; then
  mode=git
elif grep -Eq '^(rtk +)?jj( +git)? +push' <<<"$cmd"; then
  mode=jj
else
  exit 0
fi

repo="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ -n "$repo" ] && cd "$repo"

# A pushed tree whose submodule link names a commit missing from the
# submodule's own remote leaves every clone with a dangling link. Block until
# the submodule is pushed. Checks the tree being pushed: HEAD for git, the
# `main` bookmark for jj (jj ignores submodules, but the gitlink still ships).
pushed=HEAD; [ "$mode" = jj ] && pushed=main
if [ -f .gitmodules ] && git rev-parse -q --verify "$pushed^{tree}" >/dev/null 2>&1; then
  while IFS=$'\t' read -r meta path; do
    sha="${meta##* }"
    git -C "$path" rev-parse --git-dir >/dev/null 2>&1 || continue  # not checked out
    if ! git -C "$path" fetch -q origin >/dev/null 2>&1; then
      echo "guard-push: fetch in submodule $path failed; cannot confirm $sha is pushed." >&2
      exit 2
    fi
    if [ -z "$(git -C "$path" branch -r --contains "$sha" 2>/dev/null)" ]; then
      echo "guard-push: submodule $path commit $sha is not on its remote. Push the submodule first, then retry." >&2
      exit 2
    fi
  done < <(git ls-tree -r "$pushed" | awk -F'\t' '$1 ~ /^160000 /')
fi

if [ "$mode" = jj ]; then
  # jj-native reconcile of the `main` bookmark against `main@origin`. A diverging
  # fetch turns `main` into a conflicted bookmark, so drive everything off the
  # change-id captured *before* the fetch (stable across rebase, never ambiguous)
  # plus the unambiguous `main@origin`.
  [ -d .jj ] || exit 0
  lc=$(jj log --no-graph -r 'main' -T 'change_id' 2>/dev/null) || exit 0
  [ -n "$lc" ] || exit 0

  # Seam: tests drive real local remotes and leave this unset.
  if [ -n "${LITMASK_GUARD_FETCH_CMD:-}" ]; then
    eval "$LITMASK_GUARD_FETCH_CMD" >/dev/null 2>&1 || { echo "guard-push: fetch failed." >&2; exit 2; }
  elif ! jj git fetch >/dev/null 2>&1; then
    echo "guard-push: \`jj git fetch\` failed; resolve connectivity before pushing." >&2
    exit 2
  fi

  # No remote-tracking `main` => nothing to reconcile (first push establishes it).
  jj log --no-graph -r 'main@origin' -T '"x"' 2>/dev/null | grep -q x || exit 0

  # main@origin already an ancestor of local main => ahead only, fast-forwardable.
  if jj log --no-graph -r "main@origin & ::${lc}" -T '"x"' 2>/dev/null | grep -q x; then
    exit 0
  fi

  # Remote moved. Rebase the local-only commits onto it; jj records conflicts in
  # the rebased commits instead of aborting, so detect them and undo on conflict.
  jj rebase -s "roots(main@origin..${lc})" -d 'main@origin' >/dev/null 2>&1 \
    || { echo "guard-push: \`jj rebase\` onto main@origin failed." >&2; exit 2; }
  if jj log --no-graph -r "(main@origin..${lc}) & conflicts()" -T '"x"' 2>/dev/null | grep -q x; then
    jj undo >/dev/null 2>&1 || true
    jj bookmark set main -r "$lc" >/dev/null 2>&1 || true   # resolve the bookmark back to local
    echo "guard-push: main@origin moved and the rebase did not apply cleanly (conflict). Rebase and resolve manually, then push." >&2
    exit 2
  fi
  jj bookmark set main -r "$lc" >/dev/null 2>&1 || true      # move main to the rebased tip
  echo "guard-push: rebased local commits onto main@origin (remote moved); push will fast-forward." >&2
  exit 0
fi

# mode=git ---------------------------------------------------------------------

# A force-push (-f / --force / --force-with-lease) is a deliberate history
# rewrite. The reconcile-rebase below would replay the rewritten commits onto the
# old upstream; identical patch-ids make rebase drop them all, silently undoing
# the rewrite (and turning the push into a no-op). Step aside — the operator has
# explicitly opted out of fast-forward reconciliation.
grep -Eq -- '(^| )(-f|--force[a-z-]*)( |=|$)' <<<"$cmd" && exit 0

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
