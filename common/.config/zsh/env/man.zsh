#!/usr/bin/env zsh

# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X';

if command -v bat &>/dev/null; then
  # Use bat as manpager to get colorized manpages.
  # Still don't clear the screen after quitting man
  export MANPAGER="sh -c 'col -bx | bat --language man --plain --pager \"less -XRF\"'"
fi

export MANPATH="/usr/local/man:$MANPATH"
