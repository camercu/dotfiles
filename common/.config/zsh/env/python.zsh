#!/usr/bin/env zsh

# ensure uv tools are in PATH
if command -v uv &>/dev/null; then
  export PATH="$(uv tool dir):$PATH"
fi

# put .python_history in $XDG_CACHE_HOME
export PYTHON_HISTORY=${XDG_CACHE_HOME:-$HOME/.cache}/python/history
