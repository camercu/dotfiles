#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
DOTFILE_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
. "$SCRIPT_DIR/lib/logging.sh"
FLAKE_DIR=${HOME_MANAGER_FLAKE_DIR:-$DOTFILE_DIR}
FLAKE_URI=${HOME_MANAGER_FLAKE_URI:-path:$FLAKE_DIR}
HOSTS_FILE=${HOME_MANAGER_HOSTS_FILE:-$DOTFILE_DIR/common/.config/home-manager/hosts.tsv}
HOST_HELPER=$SCRIPT_DIR/home-manager-host.sh

if ! command -v nix >/dev/null 2>&1; then
  error "nix is required before Home Manager can be applied"
  exit 1
fi

RAW_NAME=${1:-$("$HOST_HELPER" current-name)}

if [ $# -gt 0 ]; then
  shift
fi

if ! CONFIG_NAME=$("$HOST_HELPER" resolve-config "$RAW_NAME"); then
  error "no Home Manager config matched '$RAW_NAME' in $HOSTS_FILE"
  exit 1
fi

if HOST_SYSTEM=$("$HOST_HELPER" lookup-system "$RAW_NAME" 2>/dev/null); then
  case "$HOST_SYSTEM" in
    *-darwin)
      error "macOS Home Manager is managed through nix-darwin; use darwin-rebuild for '$CONFIG_NAME'"
      exit 1
      ;;
  esac
fi

nix --extra-experimental-features 'nix-command flakes' \
  run home-manager/release-25.05 -- \
  switch -b hm-backup --flake "$FLAKE_URI#$CONFIG_NAME" "$@"
