#!/usr/bin/env bash
# Global PreToolUse guard: refuse a build/test chained before `git commit` in a
# single command. rtk (the global Bash hook) wraps cargo/git and on some paths
# returns its own exit status, so a failing `cargo nextest run && git commit`
# still runs the commit — landing it mid-red. The check must be its own command,
# green confirmed from its own output, before a separate commit.
#
# Anchored to the command start so the same text inside a commit-message string
# does not false-fire; no-ops (exit 0) on anything that isn't such a chain, so
# it idles harmlessly in non-cargo repos. Exit 2 blocks.
set -euo pipefail

cmd="$(jq -r '.tool_input.command // ""')"
if grep -Eq '^(rtk +)?(nextest|cargo +(test|nextest|build|check|run)|just +(test|ci|build|pre-push|pre-commit)).*(&&|;|\|\|).*git +commit' <<<"$cmd"; then
  echo "guard-commit-chain: don't chain a build/test with 'git commit' (rtk can mask a failed exit, landing the commit mid-red). Run the check as its own command, confirm it passed, then commit separately." >&2
  exit 2
fi
exit 0
