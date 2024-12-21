#!/usr/bin/env zsh

# enable coloring in terminal
export CLICOLOR=1

# Load Color constants into environment
#
# To read source of colors function, do:
# less $^fpath/colors(N)
#
# source: https://stackoverflow.com/a/6159885
autoload -U colors && colors
for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
    eval export $COLOR='$fg_no_bold[${(L)COLOR}]'
    eval export BOLD_$COLOR='$fg_bold[${(L)COLOR}]'
done
eval export RESET='$reset_color'
