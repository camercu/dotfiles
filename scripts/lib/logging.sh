#!/bin/sh

__log_color() {
  if [ -t 2 ] && [ -n "${TERM:-}" ] && command -v tput >/dev/null 2>&1; then
    tput setaf "$1" 2>/dev/null || true
  fi
}

__log_clear() {
  if [ -t 2 ] && [ -n "${TERM:-}" ] && command -v tput >/dev/null 2>&1; then
    tput sgr0 2>/dev/null || true
  fi
}

__log_message() {
  prefix=$1
  color=$2
  shift 2

  color_code=$(__log_color "$color")
  clear_code=$(__log_clear)
  printf '%s%s %s%s\n' "$color_code" "$prefix" "$*" "$clear_code" >&2
}

info() {
  __log_message "[*]" 4 "$@"
}

warn() {
  __log_message "[!]" 3 "$@"
}

error() {
  __log_message "[x]" 1 "$@"
}

success() {
  __log_message "[+]" 2 "$@"
}

debug() {
  info "$@"
}
