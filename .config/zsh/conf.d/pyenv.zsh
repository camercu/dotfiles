#!/usr/bin/env zsh

# configure pyenv
if is-command-defined pyenv; then
    export PYENV_ROOT="$XDG_CONFIG_HOME/pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    export PIPENV_IGNORE_VIRTUALENVS=1
fi
