#!/usr/bin/env bash
# Controls for the rtk setup agents run under: which commands the Claude hook
# rewrites (~/Library/Application Support/rtk/config.toml exclude_commands),
# and the rtk binary's own regressions seen in agent transcripts.
# Usage: RTK=/path/to/rtk scripts/test-rtk.sh   (default: rtk on PATH)
set -euo pipefail

rtk="${RTK:-rtk}"
# A missing binary would make every "raw" control pass vacuously.
"$rtk" --version >/dev/null 2>&1 || { echo "FAIL rtk does not run: $rtk"; exit 1; }
fails=0
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

ok() { printf 'ok   %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1"; fails=$((fails + 1)); }

rewrite() {
  jq -nc --arg c "$1" '{hook_event_name:"PreToolUse",tool_name:"Bash",tool_input:{command:$c}}' |
    "$rtk" hook claude 2>/dev/null | jq -r '.hookSpecificOutput.updatedInput.command // empty' 2>/dev/null || true
}

# Lossy or wrong in transcripts (git log cap, stripped bodies, false "ok" on a
# failed commit, diff "identical", hidden logs, grep regex errors, worktree
# guard refusals of `rtk git`): these must reach the agent unrewritten.
for cmd in 'git log --format=%b' 'git commit -m x' 'cd /tmp && git status' 'cat build.log' \
  'head -50 f' "grep -n 'a\\|b' f" 'find . -name x -not -path y' 'diff a b' 'dig +short x'; do
  out="$(rewrite "$cmd")"
  [ -z "$out" ] || [ "$out" = "$cmd" ] && ok "raw: $cmd" || fail "raw: $cmd  (rewritten to: $out)"
done

# Test runners carry most of rtk's real savings; keep them compressed.
for cmd in 'cargo test' 'ls -la'; do
  case "$(rewrite "$cmd")" in rtk\ *) ok "compressed: $cmd" ;; *) fail "compressed: $cmd" ;; esac
done

# Binary regressions, for when an excluded command is run through rtk anyway.
# Not controlled: `rtk git log` still stops at 50 commits without notice in
# 1.0.1, which is why git stays excluded above.
cd "$scratch"
printf 'alpha\nfork(x)\n' >f
"$rtk" grep -n 'alpha\|fork(' f >/dev/null 2>&1 && ok "rtk grep reads ( as literal in BRE" || fail "rtk grep turns BRE ( into a regex group"
"$rtk" find . -name f -not -path './.git/*' >/dev/null 2>&1 && ok "rtk find accepts -not" || fail "rtk find rejects -not"

[ "$fails" -eq 0 ] && echo "all rtk controls passed" || { echo "$fails rtk control(s) failed"; exit 1; }
