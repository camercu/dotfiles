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
# Claude Code frontmatter keys beyond the Agent Skills spec
# (https://code.claude.com/docs/en/skills).
fixture harness-keys       $'when_to_use: x\narguments: x\ndisallowed-tools: x\neffort: high\nbackground: true\nhooks: {}\npaths: x\nshell: bash\nuser-invocable: false\n' "Use when testing." "Body."
fixture short-bad-compat   $'compatibility: [1]\n'          "Use when testing."  "Body."
fixture Bad_Case           ""                               "Use when testing."  "Body."
fixture "$(printf 'a%.0s' $(seq 65))" ""                       "Use when testing."  "Body."
fixture long-description   ""                               "Use when $(printf 'x%.0s' $(seq 1030))." "Body."
fixture gt-bracket         ""                               "Use when a > b."    "Body."
mkdir -p "$scratch/name-mismatch" && printf -- '---\nname: other\ndescription: Use when testing.\n---\n\nBody.\n' >"$scratch/name-mismatch/SKILL.md"
mkdir -p "$scratch/not-a-dict" && printf -- '---\n- a\n---\n\nBody.\n' >"$scratch/not-a-dict/SKILL.md"
fixture int-key            $'1: x\n'                        "Use when testing."  "Body."
fixture not-utf8           ""                               "Use when testing."  "$(printf 'caf\351')"
mkdir -p "$scratch/empty-name" && printf -- '---\nname: ""\ndescription: Use when testing.\n---\n\nBody.\n' >"$scratch/empty-name/SKILL.md"
fixture empty-description  ""                               '""'                 "Body."

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
expect empty-name         "'name' is empty"
expect empty-description  "'description' is empty"
expect harness-keys       "Skill is valid!"
expect short-bad-compat   "Compatibility must be a string"
expect Bad_Case           "should be kebab-case"
expect "$(printf 'a%.0s' $(seq 65))" "Name is too long"
expect long-description   "Description is too long"
expect gt-bracket         "angle brackets"
expect name-mismatch      "differs from directory"
expect not-a-dict         "must be a YAML dictionary"
expect int-key            "Unexpected key(s) in SKILL.md frontmatter: 1"
expect not-utf8           "not UTF-8"
if [ "$code" = 10 ]; then echo "ok  - exit 10 on invalid"; else echo "FAIL- exit $code, want 10"; fails=$((fails+1)); fi

# --repo: every SKILL.md git tracks under cwd, synced ones excluded.
repo="$scratch/repo"
mkdir -p "$repo/skills/valid" "$repo/skills/synced/id/no-cue"
cp "$scratch/valid/SKILL.md" "$repo/skills/valid/"
cp "$scratch/no-cue/SKILL.md" "$repo/skills/synced/id/no-cue/"
git -C "$repo" init -q && git -C "$repo" add -A
code=0; (cd "$repo" && "$validator" --repo >/dev/null 2>&1) || code=$?
if [ "$code" = 0 ]; then echo "ok  - --repo skips synced"; else echo "FAIL- --repo skips synced (exit $code)"; fails=$((fails+1)); fi
mkdir -p "$repo/skills/no-cue" && cp "$scratch/no-cue/SKILL.md" "$repo/skills/no-cue/"
git -C "$repo" add -A
code=0; (cd "$repo" && "$validator" --repo >/dev/null 2>&1) || code=$?
if [ "$code" = 10 ]; then echo "ok  - --repo checks tracked"; else echo "FAIL- --repo checks tracked (exit $code)"; fails=$((fails+1)); fi

echo "---"
if [ "$fails" -eq 0 ]; then
  echo "all validator rule controls passed"
  exit 0
fi
echo "$fails failed"
exit 1
