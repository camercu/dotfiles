#!/usr/bin/env zsh

__lib_dir="$(cd "$(dirname "$0")" && pwd -P)/lib"
source "$__lib_dir/logging.sh"
source "$__lib_dir/shell-lib.sh"
unset __lib_dir

# Set computer name
if is_admin; then
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
fi

