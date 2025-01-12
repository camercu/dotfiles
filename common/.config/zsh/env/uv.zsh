#!/usr/bin/env zsh

# ensure uv tools are in PATH
if command -v uv &>/dev/null; then
  export PATH="$(uv tool dir):$PATH"
fi
