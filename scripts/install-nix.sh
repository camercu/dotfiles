#!/usr/bin/env zsh

if ! command -v nix; then
    # https://zero-to-nix.com/concepts/nix-installer/
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
fi

