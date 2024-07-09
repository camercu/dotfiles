#!/usr/bin/env zsh

# eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/powerlevel10k_rainbow.omp.json)"
# eval "$(oh-my-posh init zsh --config ${XDG_CONFIG_HOME}/oh-my-posh/mytheme.omp.yml)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Make sure to expand tilde to home directory
set -o magicequalsubst

#
# Environment Variables
#
for envfile in $ZDOTDIR/env/*.zsh; do
    source "$envfile"
done
unset envfile

#
# Functions
#
[ -r "$ZDOTDIR/autoloader.zsh" ] && source "$ZDOTDIR/autoloader.zsh"
autoload-dir $__zsh_config_dir/functions(N/) $__zsh_config_dir/functions/*(N/)


#
# Aliases
#
[[ -f "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"

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

# set PATH to include user's .local/bin, if it exists
[[ -d "$HOME/.local/bin" ]] && export PATH="$PATH:$HOME/.local/bin"

# set PATH so it includes user's private bin if it exists
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# set PATH to include user's .cargo dir for Rust, if it exists
[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# enable nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# configure pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    export PIPENV_IGNORE_VIRTUALENVS=1
fi

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path


#
# Tab Completions
#
autoload -U compinit && compinit -u -d "$ZSH_COMPDUMP"

# terraform completions
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

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
