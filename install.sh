#!/usr/bin/env zsh
set -e

export DOTFILE_DIR="$(cd "$(dirname ${0})" && pwd -P)" # absolute path to dir

# load env vars, including XDG_*
builtin source "$DOTFILE_DIR/common/.zshenv"

# load useful functions and aliases
# (realpath, is-macos, is-linux, logging functions)
builtin source "$DOTFILE_DIR/common/.bash_aliases"

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

# Ensure nix is installed on MacOS
if ! is-installed nix && is-macos; then
    scripts/install-nix.sh
fi
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    # Add Nix Channels
    nix-channel --add https://nixos.org/channels/nixpkgs-24.11-darwin nixpkgs
    nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs-unstable
    nix-channel --update
fi

# install homebrew if admin user on MacOS
if ! is-installed brew && is-macos && is-admin ; then
    scripts/install-homebrew.sh
    builtin eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# install dotfiles
scripts/install-dotfiles.sh

# configure macos default settings
if is-macos; then
    scripts/config-macos.zsh
fi

# Install nix-darwin (must do after dotfiles are installed)
if is-macos && is-admin; then
  if ! is-installed darwin-rebuild; then
    nix run nix-darwin -- switch --flake $(realpath ~/.config/nix-darwin)
    zsh -c 'darwin-rebuild switch --flake $(realpath ~/.config/nix-darwin)'
  fi
fi

