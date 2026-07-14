#!/usr/bin/env bash
# Controls for guard-commit-chain.sh: a leading build/test chained with a commit
# is blocked; everything else (incl. the pattern inside a message) passes.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
guard="$here/guard-commit-chain.sh"
fails=0
hook_json() { printf '{"tool_input":{"command":%s}}' "$(printf '%s' "$1" | jq -Rs .)"; }
run_guard() { local code=0; bash "$guard" <<<"$(hook_json "$1")" >/dev/null 2>&1 || code=$?; echo "$code"; }
expect() { if [ "$2" = "$3" ]; then echo "ok  - $1"; else echo "FAIL- $1 (got $2 want $3)"; fails=$((fails+1)); fi; }

expect "nextest&&commit chain blocked"     "$(run_guard 'cargo nextest run && git commit -m x -- a.txt')" 2
expect "just-ci&&commit chain blocked"     "$(run_guard 'just ci && git commit -m x')" 2
expect "rtk-wrapped chain blocked"         "$(run_guard 'rtk cargo test && git commit -m x')" 2
expect "build without commit passes"       "$(run_guard 'cargo build && ls')" 0
expect "plain commit passes"               "$(run_guard 'git commit -m x -- a.txt')" 0
expect "pattern inside message passes"     "$(run_guard 'git commit -m "cargo test && git commit note" -- a.txt')" 0
expect "non-git command passes"            "$(run_guard 'ls -la')" 0

echo "---"
[ "$fails" -eq 0 ] && { echo "all chain-guard controls passed"; exit 0; } || { echo "$fails failed"; exit 1; }
