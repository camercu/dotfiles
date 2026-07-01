#!/usr/bin/env zsh

# enable coloring in terminal
export CLICOLOR=1

# Load Color constants as shell globals (NOT exported).
# Exporting names like RED/WHITE/BLACK pollutes every child process and clashes
# with programs that read those variables. Consumers here run in-shell.
#
# To read source of colors function, do:
# less $^fpath/colors(N)
#
# adapted from: https://stackoverflow.com/a/6159885
autoload -U colors && colors
for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
    typeset -g "${COLOR}=${fg_no_bold[${(L)COLOR}]}"
    typeset -g "BOLD_${COLOR}=${fg_bold[${(L)COLOR}]}"
done
typeset -g RESET="$reset_color"
