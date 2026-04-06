# Don't clear the screen after quitting a manual page.
export MANPAGER='less -X'

# Use bat as manpager to get colorized manpages.
if is-installed bat; then
  export MANPAGER='bat --language man --plain --pager "less -XRF"'
fi

# add local man directory to MANPATH
if [[ -n "${MANPATH:-}" ]]; then
  export MANPATH="/usr/local/share/man:/usr/local/man:${MANPATH}"
else
  export MANPATH="/usr/local/share/man:/usr/local/man"
fi
