#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
DOTFILE_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
HOSTS_FILE=${HOME_MANAGER_HOSTS_FILE:-$DOTFILE_DIR/common/.config/home-manager/hosts.tsv}

usage() {
  cat <<'EOF' >&2
Usage:
  home-manager-host.sh current-name
  home-manager-host.sh current-config
  home-manager-host.sh resolve-config <name>
  home-manager-host.sh lookup-system <name>
EOF
  exit 1
}

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

lookup_host_field() {
  target=$(normalize_name "$1")
  field=$2

  while IFS='|' read -r config_name system _username _home_directory aliases; do
    case "$config_name" in
      ""|\#*)
        continue
        ;;
    esac

    normalized_config_name=$(normalize_name "$config_name")
    if [ "$target" = "$normalized_config_name" ]; then
      case "$field" in
        config) printf '%s\n' "$config_name" ;;
        system) printf '%s\n' "$system" ;;
        *) return 1 ;;
      esac
      return 0
    fi

    old_ifs=$IFS
    IFS=','
    for alias_name in $aliases; do
      if [ "$target" = "$(normalize_name "$alias_name")" ]; then
        IFS=$old_ifs
        case "$field" in
          config) printf '%s\n' "$config_name" ;;
          system) printf '%s\n' "$system" ;;
          *) return 1 ;;
        esac
        return 0
      fi
    done
    IFS=$old_ifs
  done < "$HOSTS_FILE"

  return 1
}

command=${1:-}

case "$command" in
  current-name)
    detect_host
    ;;
  current-config)
    lookup_host_field "$(detect_host)" config
    ;;
  resolve-config)
    [ $# -eq 2 ] || usage
    lookup_host_field "$2" config
    ;;
  lookup-system)
    [ $# -eq 2 ] || usage
    lookup_host_field "$2" system
    ;;
  *)
    usage
    ;;
esac
