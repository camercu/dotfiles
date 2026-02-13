#!/usr/bin/env zsh

# Golang PATH
[[ -d "/usr/local/go/bin" ]] && export PATH="$PATH:/usr/local/go/bin"
if command -v go &>/dev/null; then
    export GOPATH="${GOPATH:-${XDG_CACHE_HOME:-$HOME/.cache}/go}"
    export PATH="$PATH:${GOPATH}/bin"
fi
