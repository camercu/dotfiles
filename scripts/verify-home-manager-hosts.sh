#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
DOTFILE_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
HOSTS_FILE=${HOME_MANAGER_HOSTS_FILE:-$DOTFILE_DIR/common/.config/home-manager/hosts.tsv}
HOST_HELPER=$SCRIPT_DIR/home-manager-host.sh
HOSTS_NIX=$DOTFILE_DIR/common/.config/home-manager/lib/hosts.nix

EXPECTED_FILE=$(mktemp "${TMPDIR:-/tmp}/hm-hosts-expected.XXXXXX")
ACTUAL_FILE=$(mktemp "${TMPDIR:-/tmp}/hm-hosts-actual.XXXXXX")

cleanup() {
  rm -f "$EXPECTED_FILE" "$ACTUAL_FILE"
}

trap cleanup EXIT HUP INT TERM

fail() {
  printf '%s\n' "$*" >&2
  exit 1
}

verify_shell_lookup() {
  lookup_name=$1
  expected_config=$2
  expected_system=$3

  actual_config=$(HOME_MANAGER_HOSTS_FILE="$HOSTS_FILE" "$HOST_HELPER" resolve-config "$lookup_name") ||
    fail "host helper could not resolve '$lookup_name'"
  [ "$actual_config" = "$expected_config" ] ||
    fail "expected '$lookup_name' to resolve to '$expected_config', got '$actual_config'"

  actual_system=$(HOME_MANAGER_HOSTS_FILE="$HOSTS_FILE" "$HOST_HELPER" lookup-system "$lookup_name") ||
    fail "host helper could not resolve a system for '$lookup_name'"
  [ "$actual_system" = "$expected_system" ] ||
    fail "expected '$lookup_name' to use '$expected_system', got '$actual_system'"
}

verify_shell_hosts() {
  while IFS='|' read -r config_name system _username _home_directory aliases; do
    case "$config_name" in
      ""|\#*)
        continue
        ;;
    esac

    verify_shell_lookup "$config_name" "$config_name" "$system"

    old_ifs=$IFS
    IFS=','
    for alias_name in $aliases; do
      [ -n "$alias_name" ] || continue
      verify_shell_lookup "$alias_name" "$config_name" "$system"
    done
    IFS=$old_ifs
  done < "$HOSTS_FILE"
}

verify_nix_hosts() {
  command -v nix-instantiate >/dev/null 2>&1 || return 0

  awk -F'|' '
    $1 != "" && $1 !~ /^#/ { print $1 "|" $2 }
  ' "$HOSTS_FILE" | LC_ALL=C sort > "$EXPECTED_FILE"

  nix-instantiate --eval --strict --json --expr "
    let
      lib = import <nixpkgs/lib>;
      hosts = import $HOSTS_NIX { inherit lib; };
    in
      map (host: { configName = host.configName; system = host.system; }) hosts.hosts
  " |
    python3 -c '
import json, sys
for host in json.load(sys.stdin):
    print("{}|{}".format(host["configName"], host["system"]))
' | LC_ALL=C sort > "$ACTUAL_FILE"

  diff -u "$EXPECTED_FILE" "$ACTUAL_FILE" >/dev/null ||
    fail "hosts.nix and hosts.tsv disagree on config/system pairs"
}

verify_shell_hosts
verify_nix_hosts
