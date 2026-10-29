#!/usr/bin/env bash
# Controls for common/.local/bin/ollama-aliases-check, with fake `curl` and
# `omp` on PATH: no server, no omp catalog.
# No -e: each control reports its own status via check.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../common/.local/bin/ollama-aliases-check"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
fails=0

mkdir -p "$scratch/bin"
# /api/show serves $FAKE_SHOW_DIR/<model named in the request body>, so a
# request for the wrong model fails like curl -f on a 404. Fails every call
# when FAKE_SERVER_DOWN.
cat >"$scratch/bin/curl" <<'FAKE'
#!/bin/sh
[ -z "${FAKE_SERVER_DOWN:-}" ] || exit 7
case "$*" in
  */api/show*)
    model=$(printf '%s' "$*" | sed -n 's/.*"model":"\([^"]*\)".*/\1/p')
    cat "$FAKE_SHOW_DIR/$model" 2>/dev/null || exit 22 ;;
esac
FAKE
cat >"$scratch/bin/omp" <<'FAKE'
#!/bin/sh
echo "$*" >>"$FAKE_LOG"
case "$*" in
  "models --json") printf '%s' "$FAKE_MODELS" ;;
esac
FAKE
chmod +x "$scratch/bin/curl" "$scratch/bin/omp"

# show NUM_CTX CAPS_JSON: an /api/show body.
show() { printf '{"capabilities":%s,"parameters":"num_ctx                        %s"}' "$2" "$1"; }
# row ID CTX INPUT_JSON: one ollama row of an `omp models --json` body.
row() { printf '{"provider":"ollama","id":"%s","contextWindow":%s,"input":%s}' "$1" "$2" "$3"; }
# models ROW...: an `omp models --json` body.
models() { local IFS=,; printf '{"models":[%s]}' "$*"; }

# run CASE MODELS_JSON [NAME SHOW_JSON]...: one Modelfile and one /api/show
# body per NAME (alias local-NAME); sets rc, out, log.
run() {
  case_dir="$scratch/$1"
  catalog=$2
  shift 2
  mkdir -p "$case_dir/models" "$case_dir/show"
  while [ "$#" -ge 2 ]; do
    printf 'FROM base:1\n' >"$case_dir/models/local-$1.Modelfile"
    printf '%s' "$2" >"$case_dir/show/local-$1:latest"
    shift 2
  done
  : >"$case_dir/log"
  rc=0
  out=$(env PATH="$scratch/bin:$PATH" FAKE_LOG="$case_dir/log" OLLAMA_ALIAS_DIR="$case_dir/models" \
    FAKE_SHOW_DIR="$case_dir/show" FAKE_MODELS="$catalog" FAKE_SERVER_DOWN="${FAKE_SERVER_DOWN:-}" \
    "$script" 2>&1) || rc=$?
  log=$(cat "$case_dir/log")
}

check() { # check NAME COMMAND...: passes when COMMAND succeeds
  name=$1
  shift
  if "$@"; then echo "ok   $name"; else echo "FAIL $name"; fails=$((fails + 1)); fi
}

has_line() { printf '%s\n' "$1" | grep -q -- "$2"; }
lacks_line() { ! has_line "$@"; }

run match "$(models "$(row local-x:latest 131072 '["text"]')")" \
  x "$(show 131072 '["completion","tools"]')"
check "omp agrees with ollama: exits 0" [ "$rc" = 0 ]
check "refreshes omp's model catalog before reading it" has_line "$log" '^models refresh$'

run ctx "$(models "$(row local-x:latest 262144 '["text"]')")" \
  x "$(show 131072 '["completion"]')"
check "context mismatch exits 1" [ "$rc" = 1 ]
check "context mismatch names both values" has_line "$out" 'local-x:latest: omp contextWindow 262144 != ollama num_ctx 131072'

run vision "$(models "$(row local-x:latest 131072 '["text","image"]')")" \
  x "$(show 131072 '["completion"]')"
check "image input without vision exits 1" [ "$rc" = 1 ]
check "image mismatch names both values" has_line "$out" 'local-x:latest: omp image input true != ollama vision false'

run two "$(models "$(row local-x:latest 262144 '["text"]')" "$(row local-y:latest 8192 '["text"]')")" \
  x "$(show 131072 '["completion"]')" y "$(show 8192 '["completion"]')"
check "mismatch before a match still exits 1" [ "$rc" = 1 ]
check "reports the mismatched alias" has_line "$out" '^local-x:latest:'
check "does not report the matching alias" lacks_line "$out" '^local-y:latest:'

run absent '{"models":[]}' x "$(show 8192 '["completion"]')"
check "alias omp does not offer: exits 0" [ "$rc" = 0 ]

FAKE_SERVER_DOWN=1 run down '{"models":[]}' x "$(show 8192 '["completion"]')"
check "server down: exits 0" [ "$rc" = 0 ]
check "server down: never calls omp" [ -z "$log" ]

[ "$fails" = 0 ] || { echo "$fails failing control(s)"; exit 1; }
