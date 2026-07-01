#!/usr/bin/env zsh
#
# shell-lib.sh: shared predicate helpers for the install/bootstrap scripts.
#
# Single source of truth for OS / admin / command checks. Pair with
# lib/logging.sh (info/warn/error/success). Sourced only by the zsh-side
# scripts, so hyphenated names and [[ ]] are fine here; POSIX-sh scripts
# (install.sh, dotsync) use their own uname/have_cmd logic instead.

# OS checks
function is-macos   { [[ "$OSTYPE" == darwin*  ]]; }
function is-linux   { [[ "$OSTYPE" == linux*   ]]; }
function is-bsd     { [[ "$OSTYPE" == *bsd*    ]]; }
function is-solaris { [[ "$OSTYPE" == solaris* ]]; }
function is-windows { [[ "$OSTYPE" == cygwin* || "$OSTYPE" == msys ]]; }

# is-installed: true if an external command is on PATH.
function is-installed { command -v "$1" >/dev/null 2>&1; }

# is-admin: true if the current user is in the macOS "admin" group.
# grep -x (exact line) avoids matching group names that merely contain "admin".
function is-admin { id -Gn 2>/dev/null | tr ' ' '\n' | grep -qx admin; }
