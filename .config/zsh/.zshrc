#!/usr/bin/env zsh

# eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/powerlevel10k_rainbow.omp.json)"
# eval "$(oh-my-posh init zsh --config ${XDG_CONFIG_HOME}/oh-my-posh/mytheme.omp.yml)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


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
autoload-dir $ZDOTDIR/functions(N/) $ZDOTDIR/functions/*(N/)


# Ignore warning for insecure permissions on completion files
ZSH_DISABLE_COMPFIX=true

# Make sure to expand tilde to home directory
set -o magicequalsubst

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f "$ZDOTDIR/p10k.zsh" ]] && source "$ZDOTDIR/p10k.zsh"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    colored-man-pages
    git
    hashcat-mode-finder
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Source custom aliases
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

# terraform completions
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path
