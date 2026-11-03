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
# when FAKE_SERVER_DOWN. A body of "timeout" fails like curl --max-time.
cat >"$scratch/bin/curl" <<'FAKE'
#!/bin/sh
echo "$*" >>"$FAKE_CURL_LOG"
[ -z "${FAKE_SERVER_DOWN:-}" ] || exit 7
case "$*" in
  */api/show*)
    model=$(printf '%s' "$*" | sed -n 's/.*"model":"\([^"]*\)".*/\1/p')
    [ "$(cat "$FAKE_SHOW_DIR/$model" 2>/dev/null)" != timeout ] || exit 28
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
# body per NAME (alias local-NAME); SHOW_JSON "-" = not served. Sets rc, out,
# log.
run() {
  case_dir="$scratch/$1"
  catalog=$2
  shift 2
  mkdir -p "$case_dir/models" "$case_dir/show"
  while [ "$#" -ge 2 ]; do
    printf 'FROM base:1\n' >"$case_dir/models/local-$1.Modelfile"
    [ "$2" = - ] || printf '%s' "$2" >"$case_dir/show/local-$1:latest"
    shift 2
  done
  : >"$case_dir/log"
  : >"$case_dir/curl.log"
  rc=0
  out=$(env PATH="$scratch/bin:$PATH" FAKE_LOG="$case_dir/log" FAKE_CURL_LOG="$case_dir/curl.log" \
    OLLAMA_ALIAS_DIR="$case_dir/models" \
    FAKE_SHOW_DIR="$case_dir/show" FAKE_MODELS="$catalog" FAKE_SERVER_DOWN="${FAKE_SERVER_DOWN:-}" \
    "$script" 2>&1) || rc=$?
  log=$(cat "$case_dir/log")
  curl_log=$(cat "$case_dir/curl.log")
}

check() { # check NAME COMMAND...: passes when COMMAND succeeds
  name=$1
  shift
  if "$@"; then echo "ok   $name"; else echo "FAIL $name"; fails=$((fails + 1)); fi
}

has_line() { printf '%s\n' "$1" | grep -q -- "$2"; }
# is_line TEXT LINE: TEXT has LINE, compared as plain text.
is_line() { printf '%s\n' "$1" | grep -qxF -- "$2"; }
lacks_line() { ! has_line "$@"; }
# every_line TEXT PATTERN: TEXT has lines and each one matches PATTERN.
every_line() { [ -n "$1" ] && ! printf '%s\n' "$1" | grep -qv -- "$2"; }

run match "$(models "$(row local-x:latest 131072 '["text"]')")" \
  x "$(show 131072 '["completion","tools"]')"
check "omp agrees with ollama: exits 0" [ "$rc" = 0 ]
check "refreshes omp's model catalog before reading it" has_line "$log" '^models refresh$'
# A wedged server must not hang maintain.
check "every server request has a time limit" every_line "$curl_log" '--max-time'

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

run other "$(models '{"provider":"openai","id":"local-x:latest","contextWindow":1,"input":["text","image"]}')" \
  x "$(show 131072 '["completion"]')"
check "same id from another provider is not compared: exits 0" [ "$rc" = 0 ]

run skip-then-check "$(models "$(row local-y:latest 262144 '["text"]')")" \
  x "$(show 8192 '["completion"]')" y "$(show 131072 '["completion"]')"
check "alias omp does not offer, then a mismatch: exits 1" [ "$rc" = 1 ]

run unserved "$(models "$(row local-x:latest 131072 '["text"]')" "$(row local-y:latest 262144 '["text"]')")" \
  x - y "$(show 131072 '["completion"]')"
check "unserved alias: exits 1" [ "$rc" = 1 ]
check "unserved alias: names it" has_line "$out" '^local-x:latest: ollama does not serve it'
check "unserved alias: still checks the rest" has_line "$out" '^local-y:latest: omp contextWindow'

# Live omp discovers rows from the same server, so an unserved alias has no row.
run unserved-unlisted '{"models":[]}' x -
check "unserved alias omp does not list: exits 1" [ "$rc" = 1 ]

run slow '{"models":[]}' x timeout
check "slow /api/show: exits 1" [ "$rc" = 1 ]
check "slow /api/show: not blamed on a missing alias" lacks_line "$out" 'does not serve'
check "slow /api/show: names the curl failure" has_line "$out" '^local-x:latest: /api/show failed (curl exit 28)$'

run none '{"models":[]}'
check "no Modelfiles: exits 1" [ "$rc" = 1 ]
check "no Modelfiles: says where it looked" is_line "$out" "ollama-aliases-check: no Modelfiles in $scratch/none/models"

# The Modelfiles ship with this repo, so stow puts them under $HOME/.config
# even when the caller has its own XDG_CONFIG_HOME.
home="$scratch/xdg/home"
mkdir -p "$home/.config/ollama" "$scratch/xdg/show"
printf 'FROM base:1\n' >"$home/.config/ollama/local-x.Modelfile"
: >"$scratch/xdg/log"
out=$(env -u OLLAMA_ALIAS_DIR PATH="$scratch/bin:$PATH" FAKE_LOG="$scratch/xdg/log" \
  FAKE_CURL_LOG="$scratch/xdg/curl.log" FAKE_SHOW_DIR="$scratch/xdg/show" FAKE_MODELS='{"models":[]}' \
  HOME="$home" XDG_CONFIG_HOME="$scratch/xdg/alt" "$script" 2>&1)
check "inherited XDG_CONFIG_HOME: still reads ~/.config/ollama" has_line "$out" '^local-x:latest: ollama does not serve it'

run absent '{"models":[]}' x "$(show 8192 '["completion"]')"
check "alias omp does not offer: exits 0" [ "$rc" = 0 ]

FAKE_SERVER_DOWN=1 run down '{"models":[]}' x "$(show 8192 '["completion"]')"
check "server down: exits 0" [ "$rc" = 0 ]
check "server down: never calls omp" [ -z "$log" ]

# The Modelfiles ship with this repo: a missing set is a broken install,
# server or not.
FAKE_SERVER_DOWN=1 run down-none '{"models":[]}'
check "server down, no Modelfiles: exits 1" [ "$rc" = 1 ]

[ "$fails" = 0 ] || { echo "$fails failing control(s)"; exit 1; }
