#!/usr/bin/env zsh

alias is-admin='groups | grep -qw admin;'

# Set computer name
if is-admin; then
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

