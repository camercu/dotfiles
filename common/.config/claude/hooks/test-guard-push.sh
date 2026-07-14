#!/usr/bin/env bash
# Positive + negative controls for guard-push.sh (the PreToolUse push guard).
#
# Builds a bare "remote" and a working clone locally (no network), then drives
# the guard through the four cases that matter: not-a-push, local-ahead-only,
# a disjoint remote move (clean rebase -> allow), and a conflicting remote move
# (rebase aborts -> block). Exercises the real `git fetch`/`git rebase` paths.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
guard="$here/guard-push.sh"
fails=0

hook_json() { printf '{"tool_input":{"command":%s}}' "$(printf '%s' "$1" | jq -Rs .)"; }
run_guard() {
  local cmd="$1" code=0
  CLAUDE_PROJECT_DIR="$PWD" bash "$guard" <<<"$(hook_json "$cmd")" >/dev/null 2>&1 || code=$?
  echo "$code"
}
expect() { if [ "$2" = "$3" ]; then echo "ok  - $1"; else echo "FAIL- $1 (got $2 want $3)"; fails=$((fails+1)); fi; }
# Asserts a shell condition without letting a failure trip `set -e`.
check() { if "${@:2}"; then echo "ok  - $1"; else echo "FAIL- $1"; fails=$((fails+1)); fi; }

root="$(mktemp -d)"; trap 'rm -rf "$root"' EXIT
git init -q --bare "$root/remote.git"
git clone -q "$root/remote.git" "$root/work" 2>/dev/null  # empty-repo warning is expected
cd "$root/work"; git config user.email t@t; git config user.name t
git checkout -q -b main
printf 'l1\n' > f.txt; git add f.txt; git commit -qm init; git push -q -u origin main

# A second clone lands a commit on the remote (simulates the release bot).
push_remote_change() { # <file> <content>
  local c="$root/other"; rm -rf "$c"; git clone -q "$root/remote.git" "$c"
  ( cd "$c"; git config user.email o@o; git config user.name o
    printf '%s\n' "$2" > "$1"; git add "$1"; git commit -qm "remote change"; git push -q origin HEAD:main )
}

# 1. non-push command: no-op, allow
expect "non-push passes" "$(run_guard 'git status')" 0

# 2. local ahead by an unpushed commit, remote unchanged: fast-forwardable, allow
printf 'l2\n' >> f.txt; git add f.txt; git commit -qm local2
expect "local-ahead ff passes" "$(run_guard 'git push')" 0
git push -q

# 3. remote moved (disjoint file) + a new local commit: guard rebases, allow
push_remote_change other.txt disjoint
printf 'l3\n' >> f.txt; git add f.txt; git commit -qm local3
expect "disjoint remote move rebased+allowed" "$(run_guard 'git push')" 0
check "rebase pulled the remote commit into local" test -f other.txt
git push -q

# 4. remote moved on the same line as an unpushed local change: conflict, block
push_remote_change f.txt REMOTE_LINE
printf 'LOCAL_LINE\n' > f.txt; git add f.txt; git commit -qm local-conflict
expect "conflicting remote move blocked" "$(run_guard 'git push')" 2
check "conflicting rebase aborted, no dangling state" test ! -e .git/rebase-merge -a ! -e .git/rebase-apply

echo "---"
[ "$fails" -eq 0 ] && { echo "all push-guard controls passed"; exit 0; } || { echo "$fails failed"; exit 1; }
