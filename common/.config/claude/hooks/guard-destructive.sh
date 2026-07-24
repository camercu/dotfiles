#!/usr/bin/env bash
# PreToolUse guard: forces a confirmation prompt before catastrophic, hard-to-
# reverse commands that the prefix-based `ask` permission list structurally
# cannot catch.
#
# The `ask` list matches only the FIRST token of a command, so it covers the
# STANDALONE forms (`cargo publish`, `git reset --hard`, `git clean`, `rm`,
# `*push`). This hook catches what slips past that:
#   1. patterns with no safe standalone form (find -delete, dd to a device, a
#      redirect onto a block device), matched anywhere; and
#   2. those same guarded commands when they sit in a compound/piped position
#      (`… && rm -rf x`), where prefix matching never sees them.
# Coverage is deliberately disjoint from the `ask` list so a standalone guarded
# command prompts once (via `ask`), not twice.
set -euo pipefail

cmd="$(jq -r '.tool_input.command // ""')"
[ -n "$cmd" ] || exit 0

ask() { # <reason>
  jq -cn --arg r "guard-destructive: $1" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:$r}}'
  exit 0
}

# 1. No safe standalone form — match anywhere in the command.
if grep -Eq -- '(^|[^[:alnum:]_])find([[:space:]]).*(-delete([[:space:]]|$)|-exec(dir)?[[:space:]]+rm)' <<<"$cmd"; then
  ask "find with -delete / -exec rm deletes matched files"
fi
if grep -Eq -- '(^|[^[:alnum:]_])dd([[:space:]]).*[[:space:]]of=/dev/' <<<"$cmd"; then
  ask "dd writing to a device (of=/dev/…) can wipe a disk"
fi
if grep -Eq -- '>[[:space:]]*/dev/(sd|disk|nvme|hd|zd)' <<<"$cmd"; then
  ask "redirect onto a block device can destroy it"
fi

# 2. Guarded commands in a compound/piped position (after ; && || | or &).
if grep -Eq -- '[;&|][[:space:]]*(rm[[:space:]]|cargo[[:space:]]+(\+[^[:space:]]+[[:space:]]+)?(publish|yank)([[:space:]]|$)|git[[:space:]][^;&|]*(reset[[:space:]]+--hard|clean)([[:space:]]|$))' <<<"$cmd"; then
  ask "a guarded command (rm / cargo publish|yank / git reset --hard|clean) in a compound command"
fi

exit 0
