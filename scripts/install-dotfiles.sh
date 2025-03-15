#!/usr/bin/env zsh

DOTFILE_DIR="$(cd "$(dirname ${0})/.." && pwd -P)" # absolute path to dir

# load env vars, including XDG_*
builtin source "$DOTFILE_DIR/common/.zshenv"

# load useful functions and aliases
# (realpath, is-macos, is-linux, logging functions)
builtin source "$DOTFILE_DIR/common/.bash_aliases"

function do_stow() {
  if is-installed stow; then
    stow -R "$@"
  else
    nix-shell -p stow --run "stow -R $@"
  fi
}

do_stow common
if is-macos; then
  do_stow macos
  if is-admin; then
    do_stow nix-darwin
  fi
elif is-linux; then
  do_stow linux
fi
