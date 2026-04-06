#!/usr/bin/env zsh

# Ghostty shell integration for zsh. This should be at the top of zshrc!
if [[ -n "${GHOSTTY_RESOURCES_DIR}" ]]; then
    builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  builtin source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Internal cache root used for compdump and powerlevel10k
: "${__zsh_cache_dir:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"
[[ -d "${__zsh_cache_dir}" ]] || mkdir -p -- "${__zsh_cache_dir}"


#
# Startup Library (env checks, logging, autoload-dir)
#
for _zf in "$ZDOTDIR"/lib/*.zsh(N); do builtin source "$_zf"; done
unset _zf

#
# Environment Variables
#
for _zf in "$ZDOTDIR"/env/***/*.(sh|zsh)(N-); do builtin source "$_zf"; done
unset _zf

#
# Configuration Options
#
for _zf in "$ZDOTDIR"/conf.d/***/*.(sh|zsh)(N-); do builtin source "$_zf"; done
unset _zf

#
# Auto-loaded Functions
#
autoload-dir "$ZDOTDIR/functions"

#
# Path
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path


#
# Prompt
#
typeset -g __p10k_dir="${__zsh_cache_dir}/powerlevel10k"
if [[ "${ZSH_ADMIN_PROMPT:-0}" == "1" ]] || (( EUID == 0 )) || [[ " $(groups 2>/dev/null) " == *" admin "* ]]; then
    builtin source "$ZDOTDIR/p10k-admin.zsh"
else
    builtin source "$ZDOTDIR/p10k.zsh"
fi
if [[ -s "${__p10k_dir}/powerlevel10k.zsh-theme" ]]; then
  builtin source "${__p10k_dir}/powerlevel10k.zsh-theme"
else
  print -P "%F{yellow}powerlevel10k not installed.%f Run: git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \"${__p10k_dir}\"" >&2
fi


#
# Plugins
#
# Load order is enforced by numeric directory prefix (glob sorts lexicographically):
#   10-*  General plugins (autosuggestions, completions, etc.)
#   20-*  Syntax highlighting (must follow all plugins that modify the command line)
#   30-*  Forge (must follow 20- so ZSH_HIGHLIGHT_PATTERNS is already a declared
#         associative array before forge's += runs, and bindkey -v is already active)
#
for plugin in "$ZDOTDIR"/plugins/[0-9]##-*/[^_]*.plugin.zsh(N-); do
  builtin source "$plugin"
done
unset plugin


#
# Initialize completions (must be last step)
#

# initialize completions with caching
[[ -n "$ZSH_COMPDUMP" ]] || export ZSH_COMPDUMP="${__zsh_cache_dir}/.zcompdump-${HOST}"
[[ -d "${ZSH_COMPDUMP:h}" ]] || mkdir -p -- "${ZSH_COMPDUMP:h}"
autoload -Uz compinit
if [[ -s "$ZSH_COMPDUMP" ]]; then
  # fast load from cache
  compinit -C -u -d "$ZSH_COMPDUMP"
else
  compinit -u -d "$ZSH_COMPDUMP"
fi

if (( $+functions[__zsh_register_custom_compdefs] )); then
  __zsh_register_custom_compdefs
fi
