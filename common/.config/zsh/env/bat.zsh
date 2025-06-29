#!/usr/bin/env zsh

if command -v bat &>/dev/null; then
  export BAT_THEME="Catppuccin Frappe"

  alias bathelp='bat --plain --language=help --pager="less -XRFS"'
  function help {
      "$@" --help 2>&1 | bathelp
  }

  alias -g -- -h='-h 2>&1 | bathelp'
  alias -g -- --help='--help 2>&1 | bathelp'
fi
