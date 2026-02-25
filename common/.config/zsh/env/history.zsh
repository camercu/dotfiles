#!/usr/bin/env zsh

#
# History save settings
#
export HISTFILE="$__zsh_cache_dir/.zsh_history"    # History filepath
export HISTSIZE=50000                   # Maximum events for internal history
export SAVEHIST=50000                   # Maximum events in history file

setopt HIST_IGNORE_SPACE                # Don't record commands prefixed with a space

