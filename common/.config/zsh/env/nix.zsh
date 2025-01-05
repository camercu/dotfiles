#!/usr/bin/env zsh

export NIX_CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nix"

if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
