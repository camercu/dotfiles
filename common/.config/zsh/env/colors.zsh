#!/usr/bin/env zsh

# enable coloring in terminal
export CLICOLOR=1

# Load Color constants into environment
#
# To read source of colors function, do:
# less $^fpath/colors(N)
#
# adapted from: https://stackoverflow.com/a/6159885
autoload -U colors && colors
for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
    typeset -gx "${COLOR}=${fg_no_bold[${(L)COLOR}]}"
    typeset -gx "BOLD_${COLOR}=${fg_bold[${(L)COLOR}]}"
done
typeset -gx RESET="$reset_color"
