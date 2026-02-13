#!/usr/bin/env zsh

# # If not in tmux, start tmux.
# if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
#   exec tmux attach
# fi

# Ghostty shell integration for zsh. This should be at the top of zshrc!
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
    builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  builtin source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Internal config/cache roots (with fallbacks for portability)
: "${__zsh_config_dir:=${ZDOTDIR:-$HOME/.config/zsh}}"
: "${__zsh_cache_dir:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"
[[ -d "${__zsh_cache_dir}" ]] || mkdir -p -- "${__zsh_cache_dir}"


#
# Helper Functions
#
builtin source "$ZDOTDIR/functions.zsh"

#
# Environment Variables
#
source-dir "$ZDOTDIR/env"

#
# Configuration Options
#
source-dir "$ZDOTDIR/conf.d"

#
# Auto-loaded Functions
#
autoload-dir $__zsh_config_dir/functions(N/) $__zsh_config_dir/functions/*(N/)

#
# Path
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path


#
# Prompt
#
typeset -g P10K_DIR="${__zsh_cache_dir}/powerlevel10k"
if [[ "${ZSH_ADMIN_PROMPT:-0}" == "1" ]] || (( EUID == 0 )) || [[ " $(groups 2>/dev/null) " == *" admin "* ]]; then
    builtin source "$ZDOTDIR/p10k-admin.zsh"
else
    builtin source "$ZDOTDIR/p10k.zsh"
fi
if [[ -s "${P10K_DIR}/powerlevel10k.zsh-theme" ]]; then
  builtin source "${P10K_DIR}/powerlevel10k.zsh-theme"
else
  print -P "%F{yellow}powerlevel10k not installed.%f Run: git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \"${P10K_DIR}\"" >&2
fi


#
# Plugins
#
for plugin in "$ZDOTDIR"/plugins/**/*.plugin.zsh(N); do
    [[ "$plugin" == */zsh-syntax-highlighting.plugin.zsh ]] && continue # must be last
    builtin source "$plugin"
done
unset plugin


#
# Initialize completions (must be last step)
#

# initialize completions with caching
[[ -n "$ZSH_COMPDUMP" ]] || export ZSH_COMPDUMP="${XDG_CACHE_HOME:-${XDG_CACHE:-$HOME/.cache}}/zsh/.zcompdump-${HOST}"
[[ -d "${ZSH_COMPDUMP:h}" ]] || mkdir -p -- "${ZSH_COMPDUMP:h}"
autoload -Uz compinit
if [[ -s "$ZSH_COMPDUMP" ]]; then
  # fast load from cache
  compinit -C -u -d "$ZSH_COMPDUMP"
else
  compinit -u -d "$ZSH_COMPDUMP"
fi

# must be sourced at end of .zshrc
if [[ -s "$ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" ]]; then
  builtin source "$ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
fi
