#!/usr/bin/env zsh

# enable nvm
export NVM_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/nvm"

# Lazy-load nvm: source on first use of any node-related command
_nvm_load() {
    unset -f nvm node npm npx yarn pnpm corepack
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
}
nvm()      { _nvm_load; nvm      "$@"; }
node()     { _nvm_load; node     "$@"; }
npm()      { _nvm_load; npm      "$@"; }
npx()      { _nvm_load; npx      "$@"; }
yarn()     { _nvm_load; yarn     "$@"; }
pnpm()     { _nvm_load; pnpm     "$@"; }
corepack() { _nvm_load; corepack "$@"; }
