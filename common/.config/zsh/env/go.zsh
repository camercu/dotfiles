#!/usr/bin/env zsh

# Golang PATH
[[ -d "/usr/local/go/bin" ]] && export PATH="$PATH:/usr/local/go/bin"
if which go &>/dev/null; then
    export PATH="$PATH:$(go env GOPATH)/bin"
    export GOPATH=$(go env GOPATH)
fi

