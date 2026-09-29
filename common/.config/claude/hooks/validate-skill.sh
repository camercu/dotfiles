#!/usr/bin/env bash
# Global PostToolUse check: after a Write/Edit to a SKILL.md, run the skill
# validator on that skill's directory. A name/directory mismatch or a
# description without trigger cues otherwise ships silently: the harness lists
# the skill fine, and only the invocation that never fires reveals it.
#
# Exit 2 feeds the validator's message back to Claude; anything other than a
# SKILL.md, or a payload without a path, exits 0.
set -euo pipefail

file="$(jq -r '.tool_input.file_path // .tool_response.filePath // ""')"
[ "$(basename "$file")" = "SKILL.md" ] || exit 0

here="$(cd "$(dirname "$0")" && pwd)"
VALIDATOR="$here/../../agents/skills/writing-for-agents/scripts/validate_skill.py"
SKILL_DIR="$(dirname "$file")"
export VALIDATOR SKILL_DIR

# Single quotes on purpose: the bash nix-shell starts expands the variables.
# shellcheck disable=SC2016
if out="$(nix-shell -p 'python3.withPackages(p: [p.pyyaml])' \
  --run 'python3 "$VALIDATOR" "$SKILL_DIR"' 2>&1)"; then
  exit 0
fi
echo "validate-skill: $out" >&2
echo "Rules: ~/.config/agents/skills/writing-for-agents/SKILL-MECHANICS.md" >&2
exit 2
