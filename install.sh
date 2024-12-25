#!/usr/bin/env zsh

DOTFILE_DIR="$(cd "$(dirname ${0})" && pwd -P)" # absolute path to dir

# load env vars, including XDG_*
source "$DOTFILE_DIR/.zshenv"

# load useful functions and aliases
# (realpath, is-macos, is-linux, logging functions)
source "$DOTFILE_DIR/.bash_aliases"

# Ensure Zsh directories exist.
() {
  local zdir
  for zdir in $@; do
    [[ -d "${(P)zdir}" ]] || \mkdir -p -- "${(P)zdir}"
  done
} __zsh_{user_data,cache}_dir XDG_{CACHE,CONFIG,DATA,STATE}_HOME USER_{BIN,SHARE}

# Also create .ssh dir
if [[ ! -d "$HOME/.ssh" ]]; then
    mkdir "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
fi

# initialize/update git submodules for dotfiles
git submodule update --init

# make archive dir if doesn't exist
ARCHIVE_DIR="${DOTFILE_DIR}/old"
mkdir -p "$ARCHIVE_DIR"

stow common

if is-macos; then
    stow macos
elif [[ is-linux ]]; then
    stow is-linux
fi

