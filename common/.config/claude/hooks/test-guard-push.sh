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
expect "push with piped output passes" "$(run_guard 'git push 2>&1 | tail -1')" 0
expect "push on a later line blocked" "$(run_guard $'git status\ngit push')" 2
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

# 5. pushed tree points at a submodule commit missing from the submodule's
#    remote: the parent's link would dangle, so block until it is pushed.
sroot="$(mktemp -d)"; trap 'rm -rf "$root" "$sroot"' EXIT
git init -q --bare "$sroot/sub.git"; git init -q --bare "$sroot/parent.git"
git clone -q "$sroot/sub.git" "$sroot/subseed" 2>/dev/null
( cd "$sroot/subseed"; git config user.email t@t; git config user.name t; git checkout -q -b main
  printf 's1\n' > s.txt; git add s.txt; git commit -qm init; git push -q -u origin main )
git clone -q "$sroot/parent.git" "$sroot/pwork" 2>/dev/null
cd "$sroot/pwork"; git config user.email t@t; git config user.name t; git checkout -q -b main
git -c protocol.file.allow=always submodule add -q "$sroot/sub.git" sub 2>/dev/null
git commit -qm "add sub"; git push -q -u origin main
( cd sub; git config user.email t@t; git config user.name t
  printf 's2\n' >> s.txt; git commit -qam unpushed )
git commit -qm "bump sub" -- sub
expect "unpushed submodule commit blocked" "$(run_guard 'git push')" 2
# A push after `&&`, `;` or `|` skipped every check below the match (seen:
# `cd … && git commit … && git push` shipped a dangling submodule link).
expect "push inside a compound command blocked" "$(run_guard 'git status && git push')" 2
expect "push after ; blocked" "$(run_guard 'cd . ; rtk git push')" 2
expect "jj push inside a compound command blocked" "$(run_guard 'jj st && jj git push')" 2
expect "push only named in a message passes" "$(run_guard 'git commit -m "push fix"')" 0
expect "pushing the submodule itself passes" "$(run_guard 'git -C sub push')" 0
( cd sub; git push -q origin HEAD:main )
expect "pushed submodule commit passes" "$(run_guard 'git push')" 0
cd "$root/work"

# ── jj backend ──────────────────────────────────────────────────────────────
# Same four cases against a colocated jj clone, driving `jj push` / `jj git push`
# through the guard's jj-native reconcile. Skipped where jj is not installed.
if command -v jj >/dev/null 2>&1; then
  jroot="$(mktemp -d)"; trap 'rm -rf "$root" "$jroot"' EXIT
  git init -q --bare "$jroot/remote.git"
  git clone -q "$jroot/remote.git" "$jroot/seed" 2>/dev/null
  ( cd "$jroot/seed"; git config user.email t@t; git config user.name t; git checkout -q -b main
    printf 'l1\n' > f.txt; git add f.txt; git commit -qm init; git push -q -u origin main )
  jj git clone --colocate "$jroot/remote.git" "$jroot/work" >/dev/null 2>&1
  cd "$jroot/work"
  jj config set --repo user.name t >/dev/null 2>&1
  jj config set --repo user.email t@t >/dev/null 2>&1

  jj_remote_change() { # <file> <content>
    local c="$jroot/other"; rm -rf "$c"; git clone -q "$jroot/remote.git" "$c"
    ( cd "$c"; git config user.email o@o; git config user.name o
      printf '%s\n' "$2" > "$1"; git add "$1"; git commit -qm "remote change"; git push -q origin HEAD:main )
  }
  jj_local() { # <file> <content> [set]
    if [ "${3:-app}" = set ]; then printf '%s\n' "$2" > "$1"; else printf '%s\n' "$2" >> "$1"; fi
    jj commit -m "$2" >/dev/null 2>&1; jj bookmark set main -r @- >/dev/null 2>&1
  }

  jj_local f.txt jl2; jj git push >/dev/null 2>&1  # sync a first local commit

  # 1. non-push command: no-op, allow
  expect "jj non-push passes" "$(run_guard 'jj status')" 0

  # 2. local ahead by an unpushed commit, remote unchanged: fast-forwardable, allow
  jj_local f.txt jl3
  expect "jj local-ahead ff passes" "$(run_guard 'jj push')" 0
  jj git push >/dev/null 2>&1

  # 3. remote moved (disjoint file) + a new local commit: guard rebases, allow
  jj_remote_change other.txt disjoint
  jj_local f.txt jl4
  expect "jj disjoint remote move rebased+allowed" "$(run_guard 'jj git push')" 0
  check "jj rebase pulled the remote commit into local" test -f other.txt
  jj git push >/dev/null 2>&1

  # 4. remote moved on the same line as an unpushed local change: conflict, block
  jj_remote_change f.txt REMOTE_LINE
  jj_local f.txt LOCAL_LINE set
  expect "jj conflicting remote move blocked" "$(run_guard 'jj push')" 2
  check "jj main is a single clean rev after block" \
    test "$(jj log --no-graph -r main -T '"x\n"' 2>/dev/null | grep -c x)" = 1
else
  echo "ok  - (jj not installed; jj push-guard cases skipped)"
fi

# Host without jq: the hook refuses rather than silently disarming.
nojq="$(mktemp -d)"
code=0; PATH="$nojq" "$BASH" "$guard" <<<'{}' >/dev/null 2>"$nojq/err" || code=$?
if [ "$code" = 2 ] && grep -q "jq not installed" "$nojq/err"; then echo "ok  - no jq: refuses"; else echo "FAIL- no jq: refuses (exit $code)"; fails=$((fails+1)); fi
rm -rf "$nojq"

echo "---"
if [ "$fails" -eq 0 ]; then
  echo "all push-guard controls passed"
  exit 0
fi
echo "$fails failed"
exit 1
