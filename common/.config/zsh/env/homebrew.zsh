#!/usr/bin/env zsh

if [[ -x /opt/homebrew/bin/brew ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

    # Defer `brew shellenv` until first explicit brew usage.
    function brew() {
      unfunction brew
      eval "$(/opt/homebrew/bin/brew shellenv)"
      command brew "$@"
    }
fi
