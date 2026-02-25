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
function is-installed { (( $+commands[$1] )); }
function is-command-defined { whence -w -- "$1" &>/dev/null; }
function is-function { (( $+functions[$1] )); }

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
    for zdir in "$@"; do
        [[ -d "$zdir" ]] || continue
        fpath=("$zdir" $fpath)
        # match all plain files except those starting with underscore, grabbing basename of file, with NULL_GLOB set
        zautoloads=($zdir/*~_*(N.:t))
        (( $#zautoloads > 0 )) && autoload -Uz $zautoloads
    done
}


# source-dir: Source all *.sh and *.zsh files in a
# directory (non-recursive). Skips files not owned by the current
# user or that are world-writable.
function source-dir {
    local zdir=$1
    local scriptfile owner perms
    if [[ ! -d $zdir ]]; then
        error "directory not found: $zdir"
        return 1
    fi
    for scriptfile in $zdir/*.(sh|zsh)(N.); do
        if is-macos; then
            owner=$(stat -f '%u' "$scriptfile" 2>/dev/null)
            perms=$(stat -f '%OLp' "$scriptfile" 2>/dev/null)
        else
            owner=$(stat -c '%u' "$scriptfile" 2>/dev/null)
            perms=$(stat -c '%a' "$scriptfile" 2>/dev/null)
        fi
        if [[ "$owner" != "$UID" ]]; then
            warn "skipping file not owned by current user: $scriptfile"
            continue
        fi
        if (( 8#$perms & 0002 )); then
            warn "skipping world-writable file: $scriptfile"
            continue
        fi
        builtin source "$scriptfile"
    done
}

# zsh-health: quick syntax and dependency check for this zsh config.
function zsh-health {
    local root="${ZDOTDIR:-$HOME/.config/zsh}"
    local -a files deps missing insecure

    files=(
        "$root/.zshrc"
        "$root/functions.zsh"
        "$root"/env/*.zsh(N)
        "$root"/conf.d/*.zsh(N)
        "$root"/completions/_*(N)
        "$root"/plugins/**/*.plugin.zsh(N)
    )

    if ! command zsh -n -- $files; then
        error "syntax check failed"
        return 1
    fi

    deps=(git awk sed grep)
    missing=()
    for dep in $deps; do
        (( $+commands[$dep] )) || missing+="$dep"
    done

    if (( $#missing > 0 )); then
        warn "missing recommended tools: ${missing[*]}"
    fi

    autoload -Uz compaudit
    insecure=( ${(f)"$(compaudit 2>/dev/null)"} )
    if (( $#insecure > 0 )); then
        warn "compaudit found insecure paths:"
        print -l -- "${insecure[@]}" >&2
    fi

    success "zsh config health check passed"
    return 0
}
