#!/usr/bin/env zsh

#
# Tab Completions
#

#
# Options
#
# https://zsh.sourceforge.io/Doc/Release/Options.html#Completion-4

setopt ALWAYS_TO_END        # Move cursor to end of completion suggestion.

#
# Matcher Options
#
# try case insensitive, allow partial completion before ._-,
# allow partial completion from end of word
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# to prefer exact match first, add `''` after matcher-list

# Initialize completions
autoload -U compinit
zmodload zsh/complist # give bindkey access to 'menuselect'

compinit -u -d "$ZSH_COMPDUMP"

# 'md' function: complete directories
if is-function md; then
    compdef _directories md
fi

# terraform completions
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

