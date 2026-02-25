#!/usr/bin/env zsh
set -e

export DOTFILE_DIR="$(cd "$(dirname ${0})" && pwd -P)" # absolute path to dir

# load env vars, including XDG_*
builtin source "$DOTFILE_DIR/common/.zshenv"

# load useful functions and aliases
# (realpath, is-macos, is-linux, logging functions)
builtin source "$DOTFILE_DIR/common/.bash_aliases"

# Ensure Zsh and XDG directories exist.
() {
  local zdir
  for zdir in $@; do
    [[ -d "${(P)zdir}" ]] || \mkdir -p -- "${(P)zdir}"
  done
} __zsh_{user_data,cache}_dir XDG_{BIN,CACHE,CONFIG,DATA,LIB,STATE}_HOME

# Migrate legacy Claude config into XDG config dir and keep compatibility symlink.
scripts/migrate-claude-config.zsh

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
    typeset -i __nix_channels_changed=0
    if ! nix-channel --list 2>/dev/null | grep -q '^nixpkgs '; then
      nix-channel --add https://nixos.org/channels/nixpkgs-25.05-darwin nixpkgs
      __nix_channels_changed=1
    fi
    if ! nix-channel --list 2>/dev/null | grep -q '^nixpkgs-unstable '; then
      nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs-unstable
      __nix_channels_changed=1
    fi
    (( __nix_channels_changed )) && nix-channel --update
    unset __nix_channels_changed
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
