#!/bin/bash

# Prints a custom-formatted timestamp.
# The timestamp has no spaces and is lexicographically sortable (filename friendly)
function now {
	date "+%Y-%m-%d@%H:%M:%S"
}

function info {
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