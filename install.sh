#!/bin/sh
set -eu

DOTFILE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif have_cmd sudo; then
    sudo "$@"
  else
    printf '%s\n' "sudo is required to install bootstrap packages" >&2
    exit 1
  fi
}

install_linux_bootstrap_packages() {
  missing_packages=

  have_cmd git || missing_packages="${missing_packages} git"
  have_cmd curl || missing_packages="${missing_packages} curl"
  have_cmd zsh || missing_packages="${missing_packages} zsh"

  if [ -z "$missing_packages" ]; then
    return 0
  fi

  case "$(uname -s)" in
    Linux)
      if have_cmd apt-get; then
        run_as_root apt-get update
        run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates $missing_packages
      elif have_cmd dnf; then
        run_as_root dnf install -y ca-certificates $missing_packages
      elif have_cmd pacman; then
        run_as_root pacman -Sy --noconfirm --needed ca-certificates $missing_packages
      elif have_cmd apk; then
        run_as_root apk add ca-certificates $missing_packages
      else
        printf '%s\n' "bootstrap packages are required but no supported package manager was found" >&2
        exit 1
      fi
      ;;
    *)
      printf '%s\n' "unsupported OS for install.sh bootstrap: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

case "$(uname -s)" in
  Darwin)
    if ! have_cmd zsh; then
      printf '%s\n' "zsh is required but was not found on macOS" >&2
      exit 1
    fi
    ;;
  Linux)
    install_linux_bootstrap_packages
    ;;
  *)
    printf '%s\n' "unsupported OS for install.sh bootstrap: $(uname -s)" >&2
    exit 1
    ;;
esac

exec zsh "$DOTFILE_DIR/scripts/install.zsh" "$@"
