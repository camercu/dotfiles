#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
DOTFILE_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
FLAKE_DIR=${HOME_MANAGER_FLAKE_DIR:-$DOTFILE_DIR/common/.config/home-manager}
FLAKE_URI=${HOME_MANAGER_FLAKE_URI:-path:$FLAKE_DIR}
HOSTS_FILE=${HOME_MANAGER_HOSTS_FILE:-$FLAKE_DIR/hosts.tsv}

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

resolve_config_name() {
  target=$(normalize_name "$1")

  while IFS='|' read -r config_name _system _username _home_directory aliases; do
    case "$config_name" in
      ""|\#*)
        continue
        ;;
    esac

    normalized_config_name=$(normalize_name "$config_name")

    if [ "$target" = "$normalized_config_name" ]; then
      printf '%s\n' "$config_name"
      return 0
    fi

    old_ifs=$IFS
    IFS=','
    for alias_name in $aliases; do
      if [ "$target" = "$(normalize_name "$alias_name")" ]; then
        IFS=$old_ifs
        printf '%s\n' "$config_name"
        return 0
      fi
    done
    IFS=$old_ifs
  done < "$HOSTS_FILE"

  return 1
}

lookup_host_system() {
  target=$(normalize_name "$1")

  while IFS='|' read -r config_name system _username _home_directory aliases; do
    case "$config_name" in
      ""|\#*)
        continue
        ;;
    esac

    normalized_config_name=$(normalize_name "$config_name")
    if [ "$target" = "$normalized_config_name" ]; then
      printf '%s\n' "$system"
      return 0
    fi

    old_ifs=$IFS
    IFS=','
    for alias_name in $aliases; do
      if [ "$target" = "$(normalize_name "$alias_name")" ]; then
        IFS=$old_ifs
        printf '%s\n' "$system"
        return 0
      fi
    done
    IFS=$old_ifs
  done < "$HOSTS_FILE"

  return 1
}

if ! command -v nix >/dev/null 2>&1; then
  printf '%s\n' "nix is required before Home Manager can be applied" >&2
  exit 1
fi

RAW_NAME=${1:-$(detect_host)}

if [ $# -gt 0 ]; then
  shift
fi

if ! CONFIG_NAME=$(resolve_config_name "$RAW_NAME"); then
  printf '%s\n' "no Home Manager config matched '$RAW_NAME' in $HOSTS_FILE" >&2
  exit 1
fi

if HOST_SYSTEM=$(lookup_host_system "$RAW_NAME"); then
  case "$HOST_SYSTEM" in
    *-darwin)
      printf '%s\n' "macOS Home Manager is managed through nix-darwin; use darwin-rebuild for '$CONFIG_NAME'" >&2
      exit 1
      ;;
  esac
fi

exec nix --extra-experimental-features 'nix-command flakes' \
  run home-manager/release-25.05 -- \
  switch -b hm-backup --flake "$FLAKE_URI#$CONFIG_NAME" "$@"
