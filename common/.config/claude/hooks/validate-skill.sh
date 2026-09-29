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

# Without jq the payload can't be read; exit 127 would be non-blocking and
# silently disarm the hook, so refuse instead.
command -v jq >/dev/null 2>&1 || { echo "validate-skill: jq not installed; skill NOT validated. Install jq." >&2; exit 2; }

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

# Validator exit 10 = verdict: skill invalid. Any other failure = it never
# ran (nix, python, crash); its stderr says why.
err="$(mktemp)"
trap 'rm -f "$err"' EXIT
code=0
out="$("$validator" "$skill_dir" 2>"$err")" || code=$?
case "$code" in
  0) exit 0 ;;
  10) ;;
  *) not_validated "validator did not run ($(tail -n 1 "$err"))" ;;
esac
echo "validate-skill: $out" >&2
echo "Rules: ~/.config/agents/skills/writing-for-agents/SKILL-MECHANICS.md" >&2
exit 2
