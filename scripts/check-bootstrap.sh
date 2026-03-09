#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
DOTFILE_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)

run_dotsync_smoke_test() {
  tmp_home=$(mktemp -d "${TMPDIR:-/tmp}/dotsync-home.XXXXXX")
  rel_target=$(python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' \
    "$DOTFILE_DIR/common/.bash_aliases" "$tmp_home")

  ln -s "$rel_target" "$tmp_home/.bash_aliases"

  HOME="$tmp_home" "$DOTFILE_DIR/common/.local/bin/dotsync" >/dev/null 2>&1
  [ -L "$tmp_home/.bash_aliases" ]
  [ "$(readlink "$tmp_home/.bash_aliases")" = "$rel_target" ]

  HOME="$tmp_home" "$SCRIPT_DIR/uninstall-dotfiles.sh" >/dev/null 2>&1
  [ ! -L "$tmp_home/.bash_aliases" ]

  rm -rf "$tmp_home"
}

sh -n \
  "$DOTFILE_DIR/install.sh" \
  "$DOTFILE_DIR/common/.local/bin/dotsync" \
  "$SCRIPT_DIR/apply-home-manager.sh" \
  "$SCRIPT_DIR/check-bootstrap.sh" \
  "$SCRIPT_DIR/home-manager-host.sh" \
  "$SCRIPT_DIR/install-nix.sh" \
  "$SCRIPT_DIR/render-gitignore.sh" \
  "$SCRIPT_DIR/uninstall-dotfiles.sh" \
  "$SCRIPT_DIR/verify-home-manager-hosts.sh"

zsh -n \
  "$SCRIPT_DIR/config-macos.zsh" \
  "$SCRIPT_DIR/install-homebrew.sh" \
  "$SCRIPT_DIR/install.zsh" \
  "$SCRIPT_DIR/migrate-claude-config.zsh" \
  "$SCRIPT_DIR/rename-mac.sh"

"$SCRIPT_DIR/verify-home-manager-hosts.sh"
run_dotsync_smoke_test
