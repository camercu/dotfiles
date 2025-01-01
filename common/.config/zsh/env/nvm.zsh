#!/usr/bin/env zsh

# enable nvm
if which nvm &>/dev/null; then
    export NVM_DIR="$XDG_CACHE_HOME/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
fi
