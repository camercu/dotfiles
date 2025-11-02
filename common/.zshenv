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
# ref: https://specifications.freedesktop.org/basedir/latest/
# plus some extensions for BIN and LIB dirs.
#
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_LIB_HOME="$HOME/.local/lib"
export XDG_STATE_HOME="$HOME/.local/state"

#
# Fish-like zsh dirs
#
export __zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
export __zsh_config_dir="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"
export __zsh_user_data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"

#
# Editor
#
export EDITOR="nvim"
export VISUAL="nvim"
export VIMCONFIG="$XDG_CONFIG_HOME/nvim"

# Language environment
export LANG=en_US.UTF-8

