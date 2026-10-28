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
# Serves FAKE_SHOW for /api/show; fails every call when FAKE_SERVER_DOWN.
cat >"$scratch/bin/curl" <<'FAKE'
#!/bin/sh
[ -z "${FAKE_SERVER_DOWN:-}" ] || exit 7
case "$*" in
  */api/show*) printf '%s' "$FAKE_SHOW" ;;
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
# models ID CTX INPUT_JSON: an `omp models --json` body with one ollama row.
models() { printf '{"models":[{"provider":"ollama","id":"%s","contextWindow":%s,"input":%s}]}' "$1" "$2" "$3"; }

# run CASE [ENV=VALUE...]: one Modelfile named local-x; sets rc, out, log.
run() {
  case_dir="$scratch/$1"
  shift
  mkdir -p "$case_dir/models"
  printf 'FROM base:1\n' >"$case_dir/models/local-x.Modelfile"
  : >"$case_dir/log"
  rc=0
  out=$(env PATH="$scratch/bin:$PATH" FAKE_LOG="$case_dir/log" OLLAMA_ALIAS_DIR="$case_dir/models" \
    "$@" "$script" 2>&1) || rc=$?
  log=$(cat "$case_dir/log")
}

check() { # check NAME COMMAND...: passes when COMMAND succeeds
  name=$1
  shift
  if "$@"; then echo "ok   $name"; else echo "FAIL $name"; fails=$((fails + 1)); fi
}

has_line() { printf '%s\n' "$1" | grep -q -- "$2"; }

run match FAKE_SHOW="$(show 131072 '["completion","tools"]')" \
  FAKE_MODELS="$(models local-x:latest 131072 '["text"]')"
check "omp agrees with ollama: exits 0" [ "$rc" = 0 ]
check "refreshes omp's model catalog before reading it" has_line "$log" '^models refresh$'

run ctx FAKE_SHOW="$(show 131072 '["completion"]')" \
  FAKE_MODELS="$(models local-x:latest 262144 '["text"]')"
check "context mismatch exits 1" [ "$rc" = 1 ]
check "context mismatch names both values" has_line "$out" 'local-x:latest: omp contextWindow 262144 != ollama num_ctx 131072'

run vision FAKE_SHOW="$(show 131072 '["completion"]')" \
  FAKE_MODELS="$(models local-x:latest 131072 '["text","image"]')"
check "image input without vision exits 1" [ "$rc" = 1 ]
check "image mismatch names both values" has_line "$out" 'local-x:latest: omp image input true != ollama vision false'

run absent FAKE_SHOW="$(show 8192 '["completion"]')" \
  FAKE_MODELS='{"models":[]}'
check "alias omp does not offer (FIM): exits 0" [ "$rc" = 0 ]

run down FAKE_SERVER_DOWN=1
check "server down: exits 0" [ "$rc" = 0 ]
check "server down: never calls omp" [ -z "$log" ]

[ "$fails" = 0 ] || { echo "$fails failing control(s)"; exit 1; }
