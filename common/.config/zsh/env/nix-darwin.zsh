#!/usr/bin/env zsh

if command -v darwin-reload &>/dev/null; then
  export PATH=/run/current-system/sw/bin:$PATH
fi
