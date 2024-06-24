#!/bin/zsh

# Shell Check - return true if current shell is zsh/bash
function is-zsh { ! (\builtin shopt) &>/dev/null && [ "${ZSH_VERSION+x}" ] ; }
function is-bash { (\builtin shopt) &>/dev/null && [ "${BASH_VERSINFO+x}" ] ; }


# OS checks
function is-macos   { [[ "$OSTYPE" == darwin*  ]] ; }
function is-linux   { [[ "$OSTYPE" == linux*   ]] ; }
function is-bsd     { [[ "$OSTYPE" == *bsd*    ]] ; }
function is-solaris { [[ "$OSTYPE" == solaris* ]] ; }
function is-windows { [[ "$OSTYPE" == cygwin* || "$OSTYPE" == msys ]] ; }

# Checks if command binary is installed on PATH
function is-installed { hash "$1" 2>/dev/null ; }

#
# Autoload function files in directory
#
##? Autoload function files in directory by adding
##? to fpath and calling autoload on each file in directory.
# source: https://github.com/mattmc3/zdotdir/blob/main/lib/autoload.zsh
function autoload-dir {
  local zdir
  local -a zautoloads
  for zdir in $@; do
    [[ -d "$zdir" ]] || continue
    fpath=("$zdir" $fpath)
    zautoloads=($zdir/*~_*(N.:t))
    (( $#zautoloads > 0 )) && autoload -Uz $zautoloads
  done
}

# Absolute path to file (does not resolve symlinks)
! is-installed abspath && \
function abspath {
    python3 -c "import os,sys; print(os.path.abspath(sys.argv[1]))" "$1"
}
# Real (canonical) path to file (resolves symlinks)
! is-installed realpath && \
function realpath {
    python3 -c "import os,sys; print(os.path.realpath(sys.argv[1]))" "$1"
}


#
# Logging Functions
#
function debug {
    local BLUE=$(tput setaf 4)
    local CLEAR=$(tput sgr0)
    echo "${BLUE}[*] $@${CLEAR}" >&2
}

function warn {
    local YELLOW=$(tput setaf 3)
    local CLEAR=$(tput sgr0)
    echo "${YELLOW}[!] $@${CLEAR}" >&2
}

function error {
    local RED=$(tput setaf 1)
    local CLEAR=$(tput sgr0)
    echo "${RED}[x] $@${CLEAR}" >&2
}

function success {
    local GREEN=$(tput setaf 2)
    local CLEAR=$(tput sgr0)
    echo "${GREEN}[+] $@${CLEAR}" >&2
}

