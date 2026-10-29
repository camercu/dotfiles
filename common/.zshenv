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

# Tools that follow XDG only when told. Here, not in .zshrc, so every zsh
# (and whatever it launches) agrees on where their files live.
# omp: config root is $HOME joined with PI_CONFIG_DIR (relative path), so
# ~/.config/omp. Data, state, and cache go under $XDG_*_HOME/omp because those
# dirs exist (`omp config init-xdg`). PI_CONFIG_FILES layers the tracked
# settings over the config.yml omp rewrites.
export PI_CONFIG_DIR=.config/omp
export PI_CONFIG_FILES="$XDG_CONFIG_HOME/agents/omp.yml"

# Disable Apple Terminal session restore files such as ~/.zsh_sessions.
export SHELL_SESSIONS_DISABLE=1

#
# Fish-like zsh dirs
#
export __zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
export __zsh_config_dir="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"
export __zsh_user_data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
#
# and bash-like equivalents
#
export ZSH_CACHE_DIR="$__zsh_cache_dir"
export ZSH_CONFIG_DIR="$__zsh_config_dir"
export ZSH_USER_DATA_DIR="$__zsh_user_data_dir"

#
# Editor
#
export EDITOR="nvim"
export VISUAL="nvim"
export VIMCONFIG="$XDG_CONFIG_HOME/nvim"

# Language environment
export LANG=en_US.UTF-8
