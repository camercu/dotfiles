#!/usr/bin/env bash
# Controls for the skill validator's rules
# (common/.config/agents/skills/writing-for-agents/scripts/validate_skill.py).
# One validator run over every fixture: each nix-shell start costs ~1s.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
validator="$here/../common/.config/agents/skills/writing-for-agents/scripts/validate_skill.py"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
fails=0

long_body="$(for i in $(seq 30); do echo "line $i"; done)"

# fixture NAME FRONTMATTER-EXTRA DESCRIPTION BODY
fixture() {
  mkdir -p "$scratch/$1"
  printf -- '---\nname: %s\ndescription: %s\n%s---\n\n%s\n' "$1" "$3" "$2" "$4" >"$scratch/$1/SKILL.md"
}

fixture valid              ""                               "Use when testing."  "$(printf '## Overview\n\nBody.')"
fixture no-cue             ""                               "Formats docs."      "Body."
fixture user-invoked       $'disable-model-invocation: true\n' "Formats docs."   "Body."
fixture short-no-overview  ""                               "Use when testing."  "Body."
fixture long-no-overview   ""                               "Use when testing."  "$long_body"
fixture long-wrong-first   ""                               "Use when testing."  "$(printf '## Steps\n\n%s' "$long_body")"
fixture empty-overview     ""                               "Use when testing."  "$(printf '## Overview\n\n## Steps\n\n%s' "$long_body")"
fixture unknown-key        $'colour: red\n'                 "Use when testing."  "Body."
fixture angle-brackets     ""                               "Use when <x>."      "Body."
fixture int-key            $'1: x\n'                        "Use when testing."  "Body."
fixture not-utf8           ""                               "Use when testing."  "$(printf 'caf\351')"

code=0
"$validator" "$scratch"/*/ >"$scratch/out" 2>&1 || code=$?

# expect FIXTURE MESSAGE-FRAGMENT: the fixture's result line contains it.
expect() {
  if grep -F "$scratch/$1/: " "$scratch/out" | grep -qF "$2"; then
    echo "ok  - $1"
  else
    echo "FAIL- $1 (want \"$2\"): $(grep -F "$scratch/$1/: " "$scratch/out" || cat "$scratch/out")"
    fails=$((fails+1))
  fi
}

expect valid              "Skill is valid!"
expect no-cue             "no trigger cue"
expect user-invoked       "Skill is valid!"
expect short-no-overview  "Skill is valid!"
expect long-no-overview   "no '## Overview' section"
expect long-wrong-first   "first section is 'Steps'"
expect empty-overview     "'## Overview' section is empty"
expect unknown-key        "Unexpected key(s) in SKILL.md frontmatter: colour"
expect angle-brackets     "angle brackets"
expect int-key            "Unexpected key(s) in SKILL.md frontmatter: 1"
expect not-utf8           "not UTF-8"
if [ "$code" = 10 ]; then echo "ok  - exit 10 on invalid"; else echo "FAIL- exit $code, want 10"; fails=$((fails+1)); fi

echo "---"
if [ "$fails" -eq 0 ]; then
  echo "all validator rule controls passed"
  exit 0
fi
echo "$fails failed"
exit 1
