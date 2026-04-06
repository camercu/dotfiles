if is-installed bat; then
  export BAT_THEME="Catppuccin Frappe"

  alias bathelp='bat --plain --language=help --pager="less -XRFS"'
  function help {
      "$@" --help 2>&1 | bathelp
  }

  # Global alias: rewrites bare '--help' anywhere on the line.
  # Note: won't match '--help=<topic>' forms.
  alias -g -- --help='--help 2>&1 | bathelp'
fi
