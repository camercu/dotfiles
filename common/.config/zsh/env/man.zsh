#!/usr/bin/env zsh

# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X';

# Use bat as manpager to get colorized manpages.
# Still don't clear the screen after quitting man
if command -v bat &>/dev/null; then
  export MANPAGER="sh -c 'col -bx | bat --language man --plain --pager \"less -XRF\"'"
fi

# add local man directory to MANPATH
if [[ -n "${MANPATH:-}" ]]; then
  export MANPATH="/usr/local/share/man:/usr/local/man:${MANPATH}"
else
  export MANPATH="/usr/local/share/man:/usr/local/man"
fi
