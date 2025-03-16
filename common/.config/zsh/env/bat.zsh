#!/usr/bin/env zsh

if command -v bat &>/dev/null; then
  BAT_THEME="Catppuccin Frappe"

  alias bathelp='bat --plain --language=help'

  function help {
      "$@" --help 2>&1 | bathelp
  }

  alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
  alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
fi
