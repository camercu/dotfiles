#!/usr/bin/env bash
# Global PostToolUse check: after a Write/Edit to a SKILL.md, run the skill
# validator on that skill's directory. A name/directory mismatch or a
# description without trigger cues otherwise ships silently: the harness lists
# the skill fine, and only the invocation that never fires reveals it.
#
# Exit 2 feeds the result back to Claude: the validator's rejection, or a
# notice that the skill went unvalidated because the validator could not run.
# Anything other than a SKILL.md, a third-party skill, or a payload without
# a path exits 0.
set -euo pipefail

file="$(jq -r '.tool_input.file_path // ""')"
[ "$(basename "$file")" = "SKILL.md" ] || exit 0
# Plugin and claude.ai-synced skills follow their authors' rules, not ours.
case "$file" in
  */.claude/plugins/* | */skills/synced/*) exit 0 ;;
esac

here="$(cd "$(dirname "$0")" && pwd)"
validator="$here/../../agents/skills/writing-for-agents/scripts/validate_skill.py"
skill_dir="$(dirname "$file")"

not_validated() {
  echo "validate-skill: $1; $skill_dir NOT validated." >&2
  echo "Run the Validate command in ~/.config/agents/skills/writing-for-agents/SKILL-MECHANICS.md by hand." >&2
  exit 2
}

# The validator prints one "<dir>: <message>" line on stdout; nix progress and
# tracebacks go to stderr. A failure without that line = validator never ran.
err="$(mktemp)"
trap 'rm -f "$err"' EXIT
if out="$("$validator" "$skill_dir" 2>"$err")"; then
  exit 0
fi
case "$out" in
  "$skill_dir: "*) ;;
  *) not_validated "validator did not run ($(tail -n 1 "$err"))" ;;
esac
echo "validate-skill: $out" >&2
echo "Rules: ~/.config/agents/skills/writing-for-agents/SKILL-MECHANICS.md" >&2
exit 2
