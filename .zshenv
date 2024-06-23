#!/bin/zsh
######################################################
# .zshenv: Zsh environment file, always loaded first.
######################################################

#
# ZDOTDIR tells zsh where to find zsh config dotfiles
#
export ZDOTDIR=$HOME/.config/zsh

#
# XDG_*_HOME variables
#
# ref: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables
#
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

#
# other user-specific dirs
#
export USER_BIN="$HOME/.local/bin"
export USER_SHARE="$HOME/.local/share"

#
# Fish-like zsh dirs
#
export __zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
export __zsh_config_dir="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"
export __zsh_user_data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"

#
# Editors & Pagers
#
export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER='nvim +Man!'
export VIMCONFIG="$XDG_CONFIG_HOME/nvim"
