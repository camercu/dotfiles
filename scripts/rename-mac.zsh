#!/usr/bin/env zsh

__lib_dir="$(cd "$(dirname "$0")" && pwd -P)/lib"
source "$__lib_dir/logging.sh"
source "$__lib_dir/checks.sh"
unset __lib_dir

if ! is_admin; then
  error "renaming the mac requires an admin account; nothing changed"
  exit 1
fi

# Set computer name
local computername="$1"
if [[ -z "${computername}" ]]; then
  if [[ "$(uname -m)" == "arm64" ]]; then
    computername="Roci"
  else
    computername="Tachi"
  fi
fi
scutil --set ComputerName "${computername}" &&
  sudo scutil --set LocalHostName "${computername}" &&
  sudo scutil --set HostName "${computername}"

