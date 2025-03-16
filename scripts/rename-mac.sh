#!/usr/bin/env zsh

# Set computer name
if is-admin; then
  local computername
  if [[ "$(uname -m)" == "arm64" ]]; then
    computername="Roci"
  else
    computername="Tachi"
  fi
  scutil --set ComputerName "${computername}" &&
    sudo scutil --set LocalHostName "${computername}" &&
    sudo scutil --set HostName "${computername}"
fi

