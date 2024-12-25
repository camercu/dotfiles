#!/usr/bin/env zsh

# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X';

export MANPATH="/usr/local/man:$MANPATH"
