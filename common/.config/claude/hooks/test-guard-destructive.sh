#!/usr/bin/env bash
# Controls for guard-destructive.sh (the PreToolUse catastrophic-command guard).
# Feeds commands through the hook and asserts it either asks (dangerous) or stays
# silent (allow). Standalone guarded commands MUST pass here — the prefix `ask`
# list owns those; this hook only catches compound/buried and no-safe-form cases.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
guard="$here/guard-destructive.sh"
fails=0

asks() { # <cmd> -> true if the hook returns an `ask` decision
  printf '{"tool_input":{"command":%s}}' "$(printf '%s' "$1" | jq -Rs .)" \
    | bash "$guard" 2>/dev/null | jq -e '.hookSpecificOutput.permissionDecision=="ask"' >/dev/null 2>&1
}
want_ask()   { if asks "$1"; then echo "ok  - asks: $1"; else echo "FAIL- should ask: $1"; fails=$((fails+1)); fi; }
want_allow() { if asks "$1"; then echo "FAIL- should allow: $1"; fails=$((fails+1)); else echo "ok  - allows: $1"; fi; }

# ── should ASK (dangerous, and past what prefix-ask can catch) ──
want_ask "find . -name '*.tmp' -delete"
want_ask "find . -type f -exec rm {} +"
want_ask "find . -type f -execdir rm {} ;"
want_ask "dd if=/dev/zero of=/dev/sda bs=1m"
want_ask "cat backup.img > /dev/disk2"
want_ask "cd build && rm -rf out"
want_ask "git status && cargo publish"
want_ask "cargo test && cargo publish --allow-dirty"
want_ask "make || git reset --hard HEAD~1"
want_ask "true; git clean -fdx"
want_ask "cargo +nightly build && cargo +stable yank --version 1.0.0"

# ── should ALLOW (safe, or standalone → owned by the prefix `ask` list) ──
want_allow "git status"
want_allow "rm file.txt"                 # standalone rm -> ask list
want_allow "rm -rf target"               # standalone rm -> ask list
want_allow "cargo publish"               # standalone -> ask list
want_allow "git reset --hard"            # standalone -> ask list
want_allow "git clean -fdx"              # standalone -> ask list
want_allow "find . -name '*.rs'"         # no -delete/-exec rm
want_allow "find src -type f -exec grep -l TODO {} +"  # -exec but not rm
want_allow "cargo build && cargo test"
want_allow "dd if=/dev/zero of=./scratch.img bs=1m count=10"  # of= not a device
want_allow "echo done > /dev/null"       # /dev/null is not a block device
want_allow "printf 'x' > out.txt"

echo "---"
if [ "$fails" -eq 0 ]; then
  echo "all destructive-guard controls passed"
  exit 0
fi
echo "$fails failed"
exit 1
