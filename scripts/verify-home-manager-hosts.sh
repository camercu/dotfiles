#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)
DOTFILE_DIR=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd -P)
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/logging.sh
. "$SCRIPT_DIR/lib/logging.sh"
HOSTS_FILE=${HOME_MANAGER_HOSTS_FILE:-$DOTFILE_DIR/common/.config/home-manager/hosts.tsv}
HOST_HELPER=$SCRIPT_DIR/home-manager-host.sh
APPLY=$SCRIPT_DIR/apply-home-manager.sh
HOSTS_NIX=$DOTFILE_DIR/common/.config/home-manager/lib/hosts.nix

EXPECTED_FILE=$(mktemp "${TMPDIR:-/tmp}/hm-hosts-expected.XXXXXX")
ACTUAL_FILE=$(mktemp "${TMPDIR:-/tmp}/hm-hosts-actual.XXXXXX")

STUB_DIR=$(mktemp -d "${TMPDIR:-/tmp}/hm-hosts-stubs.XXXXXX")

cleanup() {
  rm -f "$EXPECTED_FILE" "$ACTUAL_FILE"
  rm -rf "$STUB_DIR"
}

trap cleanup EXIT HUP INT TERM

fail() {
  error "$*"
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
  while IFS='|' read -r config_name system _username _home_directory aliases _display_name _primary_user extra_modules; do
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

    old_ifs=$IFS
    IFS=','
    for module_path in $extra_modules; do
      [ -n "$module_path" ] || continue
      [ -f "$DOTFILE_DIR/$module_path" ] ||
        fail "host '$config_name' references missing module '$module_path'"
    done
    IFS=$old_ifs
  done < "$HOSTS_FILE"
}

# hosts.nix holds the row checks; without nix they do not run at all.
have_nix() {
  command -v nix-instantiate >/dev/null 2>&1 && return 0
  warn "nix-instantiate not found: skipping hosts.nix checks"
  return 1
}

verify_nix_hosts() {
  have_nix || return 0

  awk -F'|' '
    $1 != "" && $1 !~ /^#/ { print $1 "|" $2 }
  ' "$HOSTS_FILE" | LC_ALL=C sort > "$EXPECTED_FILE"

  nix-instantiate --extra-experimental-features flakes \
    --eval --strict --json --expr "
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

# Runs $2... on a Linux host called kali, logged in as $1.
run_on_kali_as() {
  user=$1
  shift
  printf '#!/bin/sh\necho Linux\n' > "$STUB_DIR/uname"
  printf '#!/bin/sh\necho kali\n' > "$STUB_DIR/hostname"
  printf '#!/bin/sh\necho %s\n' "$user" > "$STUB_DIR/id"
  printf '#!/bin/sh\necho "$@"\n' > "$STUB_DIR/nix"
  chmod +x "$STUB_DIR/uname" "$STUB_DIR/hostname" "$STUB_DIR/id" "$STUB_DIR/nix"
  printf '%s\n' \
    'kali|aarch64-linux|kali|||||' \
    'cr4nk@kali|aarch64-linux|cr4nk|||||' > "$STUB_DIR/hosts.tsv"
  env -u HOME_MANAGER_CONFIG PATH="$STUB_DIR:$PATH" \
    HOME_MANAGER_HOSTS_FILE="$STUB_DIR/hosts.tsv" "$@"
}

current_config_as() {
  run_on_kali_as "$1" "$HOST_HELPER" current-config
}

# Fresh Kali VMs all share the hostname kali; the user tells them apart.
verify_current_config() {
  actual=$(current_config_as cr4nk) || fail "current-config failed for cr4nk on kali"
  [ "$actual" = "cr4nk@kali" ] ||
    fail "expected cr4nk on kali to pick 'cr4nk@kali', got '$actual'"

  actual=$(current_config_as bob) || fail "current-config failed for bob on kali"
  [ "$actual" = "kali" ] ||
    fail "expected bob on kali to fall back to 'kali', got '$actual'"

  actual=$(run_on_kali_as cr4nk env HOME_MANAGER_CONFIG=kali "$HOST_HELPER" current-config) ||
    fail "current-config failed for HOME_MANAGER_CONFIG=kali"
  [ "$actual" = "kali" ] ||
    fail "expected HOME_MANAGER_CONFIG=kali to win over 'cr4nk@kali', got '$actual'"
}

# apply-home-manager.sh must switch to the same config current-config picks.
verify_apply_target() {
  out=$(run_on_kali_as cr4nk "$APPLY") || fail "apply-home-manager.sh failed for cr4nk on kali"
  case "$out" in
    *"#cr4nk@kali"*) ;;
    *) fail "expected apply for cr4nk on kali to switch to '#cr4nk@kali', got '$out'" ;;
  esac
}

# hosts.nix must reject a bad row while evaluating, naming the row, so a typo
# in hosts.tsv breaks the flake at once instead of building a wrong home.
expect_nix_rejects() {
  row=$1
  why=$2
  printf '%s\n' "$row" > "$STUB_DIR/bad-hosts.tsv"
  if err=$(nix-instantiate --eval --strict --expr "
    let
      lib = import <nixpkgs/lib>;
      hosts = import $HOSTS_NIX { inherit lib; hostsFile = \"$STUB_DIR/bad-hosts.tsv\"; };
    in map (host: host.configName) hosts.hosts
  " 2>&1); then
    fail "hosts.nix accepted a row with $why: '$row'"
  fi
  case "$err" in
    *"hosts.tsv:"*) ;;
    *) fail "hosts.nix rejected a row with $why without naming it: $err" ;;
  esac
}

verify_nix_rejects_bad_rows() {
  have_nix || return 0
  expect_nix_rejects 'short|aarch64-linux|short||||' "7 fields"
  expect_nix_rejects '|aarch64-linux|kali|||||' "an empty config name"
  expect_nix_rejects 'Kali|aarch64-linux|kali|||||' "an uppercase config name"
  expect_nix_rejects 'cr4nk@kali|aarch64-linux|kali|||||' "a user part that differs from its username"
}

# pname:output of each package a Linux Home Manager config installs, one per
# line. ghostty.terminfo shares ghostty's pname, so the output tells them apart.
# shellcheck disable=SC2016 # ${...} in --apply is nix, not shell
hm_package_names() {
  nix --extra-experimental-features 'nix-command flakes' eval --raw \
    "path:$DOTFILE_DIR#homeConfigurations.\"$1\".config.home.packages" \
    --apply 'ps: builtins.concatStringsSep "\n" (map (p: "${p.pname or p.name}:${p.outputName or "out"}") ps)'
}

# Kali VMs get Ghostty from a system .deb (hackbox-init), built against the
# system's GL. A nix ghostty earlier on PATH would shadow it.
verify_system_ghostty() {
  have_nix || return 0
  for config in kali@kali cr4nk@kali; do
    names=$(hm_package_names "$config") || fail "could not evaluate $config packages"
    printf '%s\n' "$names" | grep -qx ghostty:out &&
      fail "$config installs nix ghostty; it should use the system package"
    printf '%s\n' "$names" | grep -qx ghostty:terminfo ||
      fail "$config lost ghostty terminfo: $names"
  done
  hm_package_names somnambulist | grep -qx ghostty:out ||
    fail "somnambulist no longer installs nix ghostty"
}

verify_nix_rejects_bad_rows
verify_system_ghostty
verify_apply_target
verify_shell_hosts
verify_nix_hosts
verify_current_config
