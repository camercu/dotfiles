#!/usr/bin/env zsh

# Golang PATH
[[ -d "/usr/local/go/bin" ]] && export PATH="$PATH:/usr/local/go/bin"
if which go &>/dev/null; then
    export GOPATH="${XDG_CACHE_HOME:-$HOME/.cache}/go"
    export PATH="$PATH:$(go env GOPATH)/bin"
fi

