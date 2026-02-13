#!/usr/bin/env zsh

typeset -g __zsh_compdump_cache_root="${XDG_CACHE_HOME:-${XDG_CACHE:-$HOME/.cache}}"
typeset -g __zsh_compdump_dir="${__zsh_compdump_cache_root}/zsh"
[[ -d "$__zsh_compdump_dir" ]] || mkdir -p -- "$__zsh_compdump_dir"
export ZSH_COMPDUMP="${__zsh_compdump_dir}/.zcompdump-${HOST}"
