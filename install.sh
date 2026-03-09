#!/bin/sh
set -eu

DOTFILE_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)
. "$DOTFILE_DIR/scripts/lib/logging.sh"

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif have_cmd sudo; then
    sudo "$@"
  else
    error "sudo is required to install bootstrap packages"
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
      error "bootstrap packages are required but no supported package manager was found"
      exit 1
    fi
    ;;
  *)
    error "unsupported OS for install.sh bootstrap: $(uname -s)"
    exit 1
    ;;
  esac
}

case "$(uname -s)" in
Darwin)
  if ! have_cmd zsh; then
    error "zsh is required but was not found on macOS"
    exit 1
  fi
  ;;
Linux)
  install_linux_bootstrap_packages
  ;;
*)
  error "unsupported OS for install.sh bootstrap: $(uname -s)"
  exit 1
  ;;
esac

# Keep this entrypoint POSIX-sh compatible so Linux bootstrap can install zsh
# first, then hand off to the zsh-focused installer implementation.
exec zsh "$DOTFILE_DIR/scripts/bootstrap-install.zsh" "$@"
