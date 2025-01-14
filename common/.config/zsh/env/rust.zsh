#!/usr/bin/env zsh

export RUSTUP_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/rustup"
export CARGO_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/cargo"
export PATH="${PATH}:${CARGO_HOME}/bin"
if [[ -d "$CARGO_HOME/env" ]]; then
    source "$CARGO_HOME/env"
fi
