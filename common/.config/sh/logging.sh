#!/bin/sh
# Colorized log messages — the one implementation behind every entry point:
# repo scripts (scripts/lib/logging.sh symlinks here), zsh startup
# (common/.config/zsh/lib/logging.zsh), and interactive bash/zsh
# (common/.bash_aliases). Three hand-synced copies used to live in those
# places and had already drifted apart.
#
# POSIX sh only: install.sh sources it under /bin/sh before anything is
# installed, and zsh/bash load the same file afterwards.
#
# Colors resolve once at source time rather than per call, since the copies
# this replaces forked tput twice per message on interactive shell startup.
# They stay empty when stderr is not a TTY, so piped or captured output (logs,
# CI) carries the level in its prefix alone, with no escapes to strip.

if [ -t 2 ] && [ -n "${TERM:-}" ] && command -v tput >/dev/null 2>&1; then
  _LOG_GRAY=$(tput setaf 8)
  _LOG_BLUE=$(tput setaf 4)
  _LOG_GREEN=$(tput setaf 2)
  _LOG_YELLOW=$(tput setaf 3)
  _LOG_RED=$(tput setaf 1)
  _LOG_CLEAR=$(tput sgr0)
else
  _LOG_GRAY=''
  _LOG_BLUE=''
  _LOG_GREEN=''
  _LOG_YELLOW=''
  _LOG_RED=''
  _LOG_CLEAR=''
fi

# Prefixes are the level marker of last resort (see the color note above), so
# every level needs its own.
#
# `local` is the one non-POSIX construct here (Issue 8 still lists it as
# unspecified), kept because dash, bash — including macOS /bin/sh — and zsh all
# implement it, which covers every shell that sources this file. Without it the
# scratch variables would outlive the call in an interactive shell's namespace.
__log_message() {
  local __log_prefix=$1
  local __log_color=$2
  shift 2
  printf '%s%s %s%s\n' "$__log_color" "$__log_prefix" "$*" "$_LOG_CLEAR" >&2
}

debug() { __log_message '[~]' "$_LOG_GRAY" "$@"; }
info() { __log_message '[*]' "$_LOG_BLUE" "$@"; }
success() { __log_message '[+]' "$_LOG_GREEN" "$@"; }
warn() { __log_message '[!]' "$_LOG_YELLOW" "$@"; }
error() { __log_message '[x]' "$_LOG_RED" "$@"; }
