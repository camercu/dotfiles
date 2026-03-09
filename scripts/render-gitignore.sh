#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
DOTFILE_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
IGNORE_DIR=${DOTFILES_IGNORE_DIR:-$DOTFILE_DIR/lib/dotfiles-ignore}
GITIGNORE_FILE=${DOTFILES_GITIGNORE_FILE:-$DOTFILE_DIR/.gitignore}
TMP_FILE=$(mktemp "${TMPDIR:-/tmp}/dotfiles-gitignore.XXXXXX")
OUTPUT_FILE=$(mktemp "${TMPDIR:-/tmp}/dotfiles-gitignore.out.XXXXXX")

cleanup() {
  rm -f "$TMP_FILE" "$OUTPUT_FILE"
}

trap cleanup EXIT HUP INT TERM

filter_patterns() {
  sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$1"
}

{
  echo "# BEGIN GENERATED DOTFILE ARTIFACT IGNORES"

  filter_patterns "$IGNORE_DIR/file-names.txt"
  filter_patterns "$IGNORE_DIR/dir-names.txt" | sed 's#$#/#'
  filter_patterns "$IGNORE_DIR/prefixes.txt" | sed 's#$#*#'
  filter_patterns "$IGNORE_DIR/suffixes.txt" | sed 's#^#*#'
  filter_patterns "$IGNORE_DIR/path-segments.txt" | sed 's#$#/#'

  echo "# END GENERATED DOTFILE ARTIFACT IGNORES"
} > "$TMP_FILE"

if grep -q '^# BEGIN GENERATED DOTFILE ARTIFACT IGNORES$' "$GITIGNORE_FILE"; then
  awk '
    /^# BEGIN GENERATED DOTFILE ARTIFACT IGNORES$/ { exit }
    { print }
  ' "$GITIGNORE_FILE" > "$OUTPUT_FILE"

  cat "$TMP_FILE" >> "$OUTPUT_FILE"

  awk '
    found { print }
    /^# END GENERATED DOTFILE ARTIFACT IGNORES$/ { found = 1; next }
  ' "$GITIGNORE_FILE" >> "$OUTPUT_FILE"
else
  cat "$GITIGNORE_FILE" > "$OUTPUT_FILE"
  if [ -s "$OUTPUT_FILE" ]; then
    printf '\n' >> "$OUTPUT_FILE"
  fi
  cat "$TMP_FILE" >> "$OUTPUT_FILE"
fi

mv "$OUTPUT_FILE" "$GITIGNORE_FILE"
