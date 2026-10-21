#!/usr/bin/env bash
# Controls for common/.local/bin/ollama-aliases, with fake `ollama` and `curl`
# on PATH: no server, no downloads.
# No -e: each control reports its own status via check.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../common/.local/bin/ollama-aliases"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
fails=0

mkdir -p "$scratch/bin"
cat >"$scratch/bin/ollama" <<'FAKE'
#!/bin/sh
echo "$*" >>"$FAKE_LOG"
case $1 in
  pull) echo "pulling manifest 42%" >&2
    [ -z "${FAKE_PULL_FAIL:-}" ] || { echo "Error: pull model manifest: file does not exist" >&2; exit 1; } ;;
  create) [ -z "${FAKE_CREATE_FAIL:-}" ] || { printf 'gathering\033[K\nError: bad Modelfile\n' >&2; exit 1; } ;;
esac
FAKE
cat >"$scratch/bin/curl" <<'FAKE'
#!/bin/sh
[ -z "${FAKE_SERVER_DOWN:-}" ]
FAKE
chmod +x "$scratch/bin/ollama" "$scratch/bin/curl"

# run CASE [ARGS...]: fresh Modelfile dir and log per case; sets rc, out, log.
run() {
  case_dir="$scratch/$1"
  mkdir -p "$case_dir/models"
  shift
  : >"$case_dir/log"
  rc=0
  out=$(PATH="$scratch/bin:$PATH" FAKE_LOG="$case_dir/log" OLLAMA_ALIAS_DIR="$case_dir/models" \
    "$script" "$@" 2>&1) || rc=$?
  log=$(cat "$case_dir/log")
}

check() { # check NAME COMMAND...: passes when COMMAND succeeds
  name=$1
  shift
  if "$@"; then echo "ok   $name"; else echo "FAIL $name"; fails=$((fails + 1)); fi
}

has_line() { printf '%s\n' "$1" | grep -q -- "$2"; }
lacks_escape() { ! printf '%s' "$1" | grep -q "$(printf '\033')"; }

# modelfile CASE CONTENT NAME; CONTENT is a printf format (\n, \r).
# shellcheck disable=SC2059
modelfile() { printf -- "$2" >"$scratch/$1/models/$3.Modelfile"; }

mkdir -p "$scratch/down/models"
modelfile down 'FROM base:1\n' a
FAKE_SERVER_DOWN=1 run down
check "server down: exits 0" [ "$rc" = 0 ]
check "server down: never calls the ollama CLI (it would launch Ollama.app)" [ -z "$log" ]

mkdir -p "$scratch/one/models"
modelfile one 'FROM base:1\nPARAMETER num_ctx 8192\n' local-x
run one
check "creates alias named after the file" [ "$log" = "create local-x -f $scratch/one/models/local-x.Modelfile" ]

mkdir -p "$scratch/crlf/models"
modelfile crlf 'from base:1\r\n' a
run crlf --pull
check "--pull: lowercase FROM and CRLF give a clean base name" has_line "$log" '^pull base:1$'

check "--pull: download progress reaches the terminal" has_line "$out" 'pulling manifest 42%'

mkdir -p "$scratch/pullfail/models"
modelfile pullfail 'FROM local-agent\n' a
FAKE_PULL_FAIL=1 run pullfail --pull
check "--pull: a failed pull still creates (base may be local)" has_line "$log" '^create a '
check "--pull: a failed pull alone exits 0" [ "$rc" = 0 ]

mkdir -p "$scratch/createfail/models"
modelfile createfail 'FROM base:1\n' a
FAKE_CREATE_FAIL=1 run createfail
check "create failure exits 1" [ "$rc" = 1 ]
check "create failure shows the error line" has_line "$out" 'Error: bad Modelfile'
check "create failure output has no terminal escapes" lacks_escape "$out"

run badarg --pul
check "unknown argument exits 2" [ "$rc" = 2 ]
check "unknown argument runs nothing" [ -z "$log" ]

run empty
check "empty dir says so" has_line "$out" 'no Modelfiles'

[ "$fails" = 0 ] || { echo "$fails failing control(s)"; exit 1; }
