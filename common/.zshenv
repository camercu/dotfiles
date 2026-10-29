#!/bin/zsh
# ~/.zshenv: read by every zsh that does not inherit ZDOTDIR. Point zsh at
# ~/.config/zsh and hand over: a zsh that inherits ZDOTDIR reads
# $ZDOTDIR/.zshenv directly, so the real environment lives there.
export ZDOTDIR=$HOME/.config/zsh
builtin source "$ZDOTDIR/.zshenv"
