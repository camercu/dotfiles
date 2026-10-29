#!/bin/zsh
######################################################
# .zshenv: Zsh environment file, always loaded first.
# Reached directly when ZDOTDIR is inherited, else via ~/.zshenv.
######################################################

#
# Per-tool environment: env/*.sh are POSIX exports (XDG dirs, tool file
# locations), loaded here so every zsh, interactive or not, agrees on them.
# ~/.bashrc loads the same files. env/*.zsh are interactive-only (.zshrc).
#
for _zf in "$ZDOTDIR"/env/*.sh(N-.); do builtin source "$_zf"; done
unset _zf

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
