#!/usr/bin/env zsh

# # If not in tmux, start tmux.
# if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
#   exec tmux attach
# fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Make sure to expand tilde to home directory
set -o magicequalsubst

#
# Helper Functions
#
source "$ZDOTDIR/functions.zsh"

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



# Makes the "command not found" message more beautiful and informative.
# source: https://github.com/warbacon/zsh-kickstart/blob/main/.zshrc
function command_not_found_handler {
    local RED_UNDERCURL="\033[4:3m\033[58:5:1m"
    printf "%sERROR:%s command \`%s\` not found.\n" \
        "$(printf $BOLD_RED)" "$(printf $RESET)" \
        "$(printf $RED_UNDERCURL)${1}$(printf $RESET)" \
        >&2
    return 127
}


#
# Path
#

# go path
[[ -d "/usr/local/go/bin" ]] && export PATH="$PATH:/usr/local/go/bin"
if which go &>/dev/null; then
    export PATH="$PATH:$(go env GOPATH)/bin"
    export GOPATH=$(go env GOPATH)
fi


# set PATH to include user's .cargo dir for Rust, if it exists
[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# enable nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path


#
# Prompt
#
[ ! -d "$__zsh_cache_dir/powerlevel10k" ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$__zsh_cache_dir/powerlevel10k"
source "$ZDOTDIR/p10k.zsh"
source "$__zsh_cache_dir/powerlevel10k/powerlevel10k.zsh-theme"

#
# Plugins
#
for plugin in $ZDOTDIR/plugins/**/*.plugin.zsh; do
    source $plugin
done
unset plugin
