#!/usr/bin/env zsh

#
# Bash Aliases
#
[[ -r "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"

# Easy navigation
alias d='dirs -v | head -10'
alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'

# better touch: auto-create parent dirs to touchfile
alias touch='() { if [[ -n  "$1" ]]; then mkdir -p -- "$1:h" && command touch -- "$1"; fi }'

