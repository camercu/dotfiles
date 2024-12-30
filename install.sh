#!/usr/bin/env zsh
set -e

DOTFILE_DIR="$(cd "$(dirname ${0})" && pwd -P)" # absolute path to dir

# load env vars, including XDG_*
source "$DOTFILE_DIR/common/.zshenv"

# load useful functions and aliases
# (realpath, is-macos, is-linux, logging functions)
source "$DOTFILE_DIR/common/.bash_aliases"

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

# Ensure nix is installed
if ! is-installed nix; then
    scripts/install-nix.sh
fi
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# install homebrew if admin user on MacOS
if ! is-installed brew && is-macos && is-admin ; then
    scripts/install-homebrew.sh
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Stow dotfiles
nix-shell -p stow --run 'stow common'
if is-macos; then
    nix-shell -p stow --run 'stow macos'
    scripts/macos-config.zsh
    if is-admin; then
        nix-shell -p stow --run 'stow nix-darwin'
        if ! is-installed darwin-rebuild; then
            nix run nix-darwin -- switch --flake $(realpath ~/.config/nix-darwin)
            zsh -c 'darwin-rebuild switch --flake $(realpath ~/.config/nix-darwin)'
        fi
    fi
elif is-linux; then
    nix-shell -p stow --run 'stow is-linux'
fi

