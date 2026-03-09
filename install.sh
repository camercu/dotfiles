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
    printf '%s\n' "sudo is required to install zsh for the bootstrap phase" >&2
    exit 1
  fi
}

install_zsh() {
  case "$(uname -s)" in
    Darwin)
      printf '%s\n' "zsh is required but was not found on macOS" >&2
      exit 1
      ;;
    Linux)
      if have_cmd apt-get; then
        run_as_root apt-get update
        run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y zsh
      elif have_cmd dnf; then
        run_as_root dnf install -y zsh
      elif have_cmd pacman; then
        run_as_root pacman -Sy --noconfirm zsh
      elif have_cmd apk; then
        run_as_root apk add zsh
      else
        printf '%s\n' "zsh is required but no supported package manager was found" >&2
        exit 1
      fi
      ;;
    *)
      printf '%s\n' "unsupported OS for install.sh bootstrap: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

if ! have_cmd zsh; then
  install_zsh
fi

exec zsh "$DOTFILE_DIR/scripts/install.zsh" "$@"
