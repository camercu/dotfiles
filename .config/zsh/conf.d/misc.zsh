#!/usr/bin/env zsh

setopt MULTIOS              # enable redirect to multiple streams: echo >file1 >file2
setopt LONG_LIST_JOBS       # show long list format job notifications
setopt INTERACTIVECOMMENTS  # recognize comments
setopt EXTENDED_GLOB        # extra globbing features
setopt C_BASES              # output hex numbers in std C format (e.g. 0xFF)
setopt NO_LIST_TYPES        # don't show file type mark when listing autocomplete
setopt NO_BG_NICE           # don't run background jobs at lower priority
