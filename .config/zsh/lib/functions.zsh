#!/bin/zsh

# OS checks
function is-macos   { [[ "$OSTYPE" == darwin*  ]] }
function is-linux   { [[ "$OSTYPE" == linux*   ]] }
function is-bsd     { [[ "$OSTYPE" == *bsd*    ]] }
function is-solaris { [[ "$OSTYPE" == solaris* ]] }
function is-windows { [[ "$OSTYPE" == cygwin* || "$OSTYPE" == msys ]] }
# function is-termux { [[ "$OSTYPE" == linux-android ]] }

# Checks if command binary is installed on PATH
function is-installed { hash "$1" 2>/dev/null }
