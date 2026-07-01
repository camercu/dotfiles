#!/usr/bin/env zsh

if [[ -x /opt/homebrew/bin/brew ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

    # Put brew's completions on fpath before compinit runs. `brew shellenv`
    # normally does this, but it is deferred below, so brew-package completions
    # (_brew, _docker, ...) would otherwise be missing until the first `brew`
    # call plus a shell restart. Adding the dir directly costs no subprocess.
    [[ -d /opt/homebrew/share/zsh/site-functions ]] &&
        fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

    # Defer `brew shellenv` until first explicit brew usage.
    function brew() {
      unfunction brew
      eval "$(/opt/homebrew/bin/brew shellenv)"
      command brew "$@"
    }
fi
