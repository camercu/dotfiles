#!/usr/bin/env bash
# Controls for validate-skill.sh: a broken SKILL.md edit is reported (exit 2,
# reason on stderr); a valid one and any other file pass silently.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
hook="$here/validate-skill.sh"
validator="$here/../../agents/skills/writing-for-agents/scripts/validate_skill.py"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
fails=0
hook_json() { printf '{"tool_name":"Edit","tool_input":{"file_path":%s}}' "$(printf '%s' "$1" | jq -Rs .)"; }
run_hook() { local code=0; bash "$hook" <<<"$(hook_json "$1")" >/dev/null 2>"$scratch/err" || code=$?; echo "$code"; }
expect() { if [ "$2" = "$3" ]; then echo "ok  - $1"; else echo "FAIL- $1 (got $2 want $3)"; fails=$((fails+1)); fi; }

mkdir -p "$scratch/bad-skill"
printf -- '---\nname: other-name\ndescription: Use when testing.\n---\n\nBody.\n' >"$scratch/bad-skill/SKILL.md"

mkdir -p "$scratch/good-skill"
printf -- '---\nname: good-skill\ndescription: Use when testing.\n---\n\n# T\n\n## Overview\n\nBody.\n' >"$scratch/good-skill/SKILL.md"

mkdir -p "$scratch/user-invocable"
printf -- '---\nname: user-invocable\ndescription: Use when testing.\nuser-invocable: false\n---\n\n# T\n\n## Overview\n\nBody.\n' >"$scratch/user-invocable/SKILL.md"

# A non-skill file inside a broken skill: passing proves the filename filter.
printf 'notes\n' >"$scratch/bad-skill/notes.md"
expect "non-skill file passes"       "$(run_hook "$scratch/bad-skill/notes.md")" 0

# Controls that run the validator need nix-shell.
if command -v nix-shell >/dev/null 2>&1; then
  expect "valid skill passes"          "$(run_hook "$scratch/good-skill/SKILL.md")" 0
  expect "user-invocable key passes"   "$(run_hook "$scratch/user-invocable/SKILL.md")" 0
  expect "broken skill blocked"        "$(run_hook "$scratch/bad-skill/SKILL.md")" 2
  expect "reason reaches stderr"       "$(grep -c "differs from directory" "$scratch/err")" 1
  expect "rules hint on reject"        "$(grep -c "Rules:" "$scratch/err")" 1
  expect "validator: invalid exits 10" "$("$validator" "$scratch/bad-skill" >/dev/null 2>&1; echo $?)" 10
else
  echo "skip - validator controls (nix-shell not installed)"
fi
expect "missing file_path passes"    "$(bash "$hook" <<<'{}' >/dev/null 2>&1; echo $?)" 0

# Third-party skills (plugins, claude.ai-synced) follow their authors' rules.
for root in ".claude/plugins/cache/p/skills" "agents/skills/synced/id"; do
  mkdir -p "$scratch/$root/bad-skill"
  cp "$scratch/bad-skill/SKILL.md" "$scratch/$root/bad-skill/SKILL.md"
  expect "third-party $root skipped" "$(run_hook "$scratch/$root/bad-skill/SKILL.md")" 0
done

# Host without nix-shell: PATH holds only the tools the hook needs besides it.
mkdir -p "$scratch/bin-nonix" "$scratch/bin-brokennix"
for tool in jq basename dirname mktemp tail rm; do ln -s "$(command -v "$tool")" "$scratch/bin-nonix/$tool"; done
run_hook_path() { local code=0; PATH="$1" "$BASH" "$hook" <<<"$(hook_json "$2")" >/dev/null 2>"$scratch/err" || code=$?; echo "$code"; }
expect "no nix-shell: agent told"    "$(run_hook_path "$scratch/bin-nonix" "$scratch/user-invocable/SKILL.md")" 2
expect "no nix-shell: NOT validated" "$(grep -c "NOT validated" "$scratch/err")" 1
expect "no nix-shell: no rules hint" "$(grep -c "Rules:" "$scratch/err" || true)" 0
expect "no nix-shell: cause shown"   "$(grep -c "nix-shell" "$scratch/err")" 1
expect "no nix-shell: manual hint"   "$(grep -c "Run the Validate command" "$scratch/err")" 1

# nix-shell present but failing before the validator runs (eval, network).
printf '#!/bin/sh\necho "error: nix eval failed" >&2\nexit 1\n' >"$scratch/bin-brokennix/nix-shell"
chmod +x "$scratch/bin-brokennix/nix-shell"
expect "broken nix: agent told"      "$(run_hook_path "$scratch/bin-brokennix:$scratch/bin-nonix" "$scratch/user-invocable/SKILL.md")" 2
expect "broken nix: NOT validated"   "$(grep -c "NOT validated" "$scratch/err")" 1
expect "broken nix: no rules hint"   "$(grep -c "Rules:" "$scratch/err" || true)" 0
expect "broken nix: cause shown"     "$(grep -c "nix eval failed" "$scratch/err")" 1
expect "broken nix: manual hint"     "$(grep -c "Run the Validate command" "$scratch/err")" 1

echo "---"
if [ "$fails" -eq 0 ]; then
  echo "all validate-skill controls passed"
  exit 0
fi
echo "$fails failed"
exit 1
