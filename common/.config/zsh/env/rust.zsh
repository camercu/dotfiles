#!/usr/bin/env zsh

export RUSTUP_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rustup"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export PATH="${PATH}:${CARGO_HOME}/bin"
if [[ -s "$CARGO_HOME/env" ]]; then
    source "$CARGO_HOME/env"
elif [[ -s "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi
