#!/usr/bin/env zsh

# +--------------------------------+
# | Helper functions used by zshrc |
# +--------------------------------+

#
# Environment Checks - return true if running in expected env
#

# Shell checks - check if current shell is zsh/bash
function is-zsh { ! (\builtin shopt) &>/dev/null && [ "${ZSH_VERSION+x}" ]; }
function is-bash { (\builtin shopt) &>/dev/null && [ "${BASH_VERSINFO+x}" ]; }

# OS checks - check if OS matches expectation
function is-macos { [[ "$OSTYPE" == darwin* ]]; }
function is-linux { [[ "$OSTYPE" == linux* ]]; }
function is-bsd { [[ "$OSTYPE" == *bsd* ]]; }
function is-solaris { [[ "$OSTYPE" == solaris* ]]; }
function is-windows { [[ "$OSTYPE" == cygwin* || "$OSTYPE" == msys ]]; }

# Command checks - check if command binary is installed on PATH / is defined
function is-installed { hash -- "$1" &>/dev/null; }
function is-command-defined { command -v -- "$1" &>/dev/null; }
function is-function { declare -f -- "$1" &>/dev/null; }

#
# Logging Functions - colorized printing of log messages
#
function debug {
    local BLUE=$(tput setaf 4)
    local CLEAR=$(tput sgr0)
    echo -- "${BLUE}[*] $@${CLEAR}" >&2
}

function warn {
    local YELLOW=$(tput setaf 3)
    local CLEAR=$(tput sgr0)
    echo -- "${YELLOW}[!] $@${CLEAR}" >&2
}

function error {
    local RED=$(tput setaf 1)
    local CLEAR=$(tput sgr0)
    echo -- "${RED}[x] $@${CLEAR}" >&2
}

function success {
    local GREEN=$(tput setaf 2)
    local CLEAR=$(tput sgr0)
    echo -- "${GREEN}[+] $@${CLEAR}" >&2
}

# autoload-dir: Autoload function files in directory by adding
# to fpath and calling autoload on each file in directory.
# source: https://github.com/mattmc3/zdotdir/blob/main/lib/autoload.zsh
function autoload-dir {
    local zdir
    local -a zautoloads
    setopt EXTENDED_GLOB LOCAL_OPTIONS
    for zdir in $@; do
        [[ -d "$zdir" ]] || continue
        fpath=("$zdir" $fpath)
        # match all plain files except those starting with underscore, grabbing basename of file, with NULL_GLOB set
        zautoloads=($zdir/*~_*(N.:t))
        (( $#zautoloads > 0 )) && autoload -Uz $zautoloads
    done
}


# source-dir: Source all *.sh and *.zsh files in a
# directory (non-recursive)
function source-dir {
    local zdir=$1
    local scriptfile
    if [[ ! -d $zdir ]]; then
        error "directory not found: $zdir"
        return 1
    fi
    for scriptfile in $zdir/*.(sh|zsh)(N.); do
        builtin source $scriptfile
    done
}
