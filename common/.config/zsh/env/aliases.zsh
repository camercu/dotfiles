#!/usr/bin/env zsh

#
# Bash Aliases
#
[[ -s "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"

#
# Zsh-specific Aliases
#

# Easy navigation
alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'

function d () {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}

# better touch: auto-create parent dirs to touchfile
alias touch='() { if [[ -n  "$1" ]]; then mkdir -p -- "$1:h" && command touch -- "$1"; fi }'

# share/sync zsh-history between sessions
alias share-hist='fc -RI'
