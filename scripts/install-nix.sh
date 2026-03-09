#!/bin/sh
set -eu

if command -v nix >/dev/null 2>&1; then
  exit 0
fi

if [ "$(uname -s)" = "Linux" ] && [ ! -d /run/systemd/system ]; then
  set -- install linux --no-confirm --init none

  if [ -f /.dockerenv ] || [ -f /run/.containerenv ] || [ -n "${container:-}" ]; then
    set -- "$@" --extra-conf "sandbox = false"
  fi
else
  set -- install --no-confirm
fi

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix |
  sh -s -- "$@"
