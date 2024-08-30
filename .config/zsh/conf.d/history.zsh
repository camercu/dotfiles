#!/usr/bin/env zsh

# +-----------------+
# | HISTORY OPTIONS |
# +-----------------+
#
# https://zsh.sourceforge.io/Doc/Release/Options.html#History

setopt HIST_EXPIRE_DUPS_FIRST   # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS         # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS     # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS        # Do not display a previously found event.
setopt HIST_IGNORE_SPACE        # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS        # Do not write a duplicate event to the history file.
setopt HIST_VERIFY              # Do not execute immediately upon history expansion.
setopt INC_APPEND_HISTORY       # Add each command to history file as it is executed;
                                # can share history between sessions with `fc -RI`

