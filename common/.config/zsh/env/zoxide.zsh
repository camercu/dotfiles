#!/usr/bin/env zsh

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init --cmd j zsh)"
fi
