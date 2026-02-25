#!/usr/bin/env zsh

# ensure uv tools are in PATH
if command -v uv &>/dev/null; then
  typeset -g __uv_tool_dir_cache="${XDG_CACHE_HOME:-$HOME/.cache}/uv/tool-dir"
  typeset -g __uv_tool_dir="${XDG_DATA_HOME:-$HOME/.local/share}/uv/tools"

  # Fast path: avoid running `uv tool dir` at startup.
  if [[ -r "$__uv_tool_dir_cache" ]]; then
    __uv_tool_dir="$(<"$__uv_tool_dir_cache")"
  fi
  [[ -d "$__uv_tool_dir" ]] && export PATH="$__uv_tool_dir:$PATH"
  unset __uv_tool_dir

  # Resolve and cache the canonical tool dir only when uv is first invoked.
  function uv() {
    unfunction uv
    local dir
    dir="$(command uv tool dir 2>/dev/null)"
    if [[ -n "$dir" ]]; then
      [[ ":$PATH:" == *":$dir:"* ]] || export PATH="$dir:$PATH"
      [[ -d "${__uv_tool_dir_cache:h}" ]] || mkdir -p -- "${__uv_tool_dir_cache:h}" 2>/dev/null
      { print -r -- "$dir" >| "$__uv_tool_dir_cache"; } 2>/dev/null || true
    fi
    command uv "$@"
  }
fi

# put .python_history in $XDG_CACHE_HOME
export PYTHON_HISTORY=${XDG_CACHE_HOME:-$HOME/.cache}/python/history
