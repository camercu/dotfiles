#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
DOTFILE_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
FLAKE_DIR=${HOME_MANAGER_FLAKE_DIR:-$DOTFILE_DIR/common/.config/home-manager}

detect_host() {
  if [ -n "${HOME_MANAGER_CONFIG:-}" ]; then
    printf '%s\n' "$HOME_MANAGER_CONFIG"
    return
  fi

  if [ "$(uname -s)" = "Darwin" ] && command -v scutil >/dev/null 2>&1; then
    scutil --get ComputerName
    return
  fi

  hostname -s
}

normalize_name() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]_-'
}

if ! command -v nix >/dev/null 2>&1; then
  printf '%s\n' "nix is required before Home Manager can be applied" >&2
  exit 1
fi

CONFIG_NAME=${1:-$(normalize_name "$(detect_host)")}

if [ $# -gt 0 ]; then
  shift
fi

exec nix --extra-experimental-features 'nix-command flakes' \
  run home-manager/release-25.05 -- \
  switch -b hm-backup --flake "$FLAKE_DIR#$CONFIG_NAME" "$@"
