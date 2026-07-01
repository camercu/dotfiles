#!/usr/bin/env zsh

#
# History save settings
#
export HISTFILE="$__zsh_cache_dir/.zsh_history"    # History filepath
export HISTSIZE=50000                   # Maximum events for internal history
export SAVEHIST=50000                   # Maximum events in history file

# History behavior options live in conf.d/history.zsh (incl. HIST_IGNORE_SPACE).
