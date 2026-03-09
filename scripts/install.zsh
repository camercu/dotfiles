#!/usr/bin/env zsh
set -e

export DOTFILE_DIR="$(cd "$(dirname ${0})/.." && pwd -P)"
typeset -r SCRIPTS_DIR="$DOTFILE_DIR/scripts"

# load env vars, including XDG_*
builtin source "$DOTFILE_DIR/common/.zshenv"

# load useful functions and aliases
# (realpath, is-macos, is-linux, logging functions)
builtin source "$DOTFILE_DIR/common/.bash_aliases"

ensure_shell_directories() {
  local zdir
  for zdir in __zsh_{user_data,cache}_dir XDG_{BIN,CACHE,CONFIG,DATA,LIB,STATE}_HOME; do
    [[ -d "${(P)zdir}" ]] || \mkdir -p -- "${(P)zdir}"
  done
}

ensure_ssh_directory() {
  if [[ ! -d "$HOME/.ssh" ]]; then
    mkdir "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
  fi
}

ensure_git_safe_directory() {
  if ! git config --global --get-all safe.directory 2>/dev/null | grep -Fx -- "$DOTFILE_DIR" >/dev/null; then
    git config --global --add safe.directory "$DOTFILE_DIR"
  fi
}

update_git_submodules() {
  git submodule update --init
}

migrate_claude_config() {
  "$SCRIPTS_DIR/migrate-claude-config.zsh"
}

ensure_nix_installed() {
  if ! is-installed nix && { is-macos || is-linux; }; then
    "$SCRIPTS_DIR/install-nix.sh"
  fi
}

configure_nix_channels() {
  typeset -i nix_channels_changed=0

  if ! nix-channel --list 2>/dev/null | grep -q '^nixpkgs '; then
    if is-macos; then
      nix-channel --add https://nixos.org/channels/nixpkgs-25.05-darwin nixpkgs
    else
      nix-channel --add https://nixos.org/channels/nixos-25.05 nixpkgs
    fi
    nix_channels_changed=1
  fi

  if ! nix-channel --list 2>/dev/null | grep -q '^nixpkgs-unstable '; then
    nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs-unstable
    nix_channels_changed=1
  fi

  if (( nix_channels_changed )); then
    nix-channel --update
  fi
}

load_nix_environment() {
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    configure_nix_channels
  fi
}

ensure_homebrew() {
  if ! is-installed brew && is-macos && is-admin; then
    "$SCRIPTS_DIR/install-homebrew.sh"
    builtin eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

install_dotfiles() {
  "$SCRIPTS_DIR/install-dotfiles.sh"
}

remove_bootstrap_dotfiles() {
  "$SCRIPTS_DIR/uninstall-dotfiles.sh"
}

configure_macos_defaults() {
  if is-macos; then
    "$SCRIPTS_DIR/config-macos.zsh"
  fi
}

ensure_nix_darwin() {
  if is-macos && is-admin && ! is-installed darwin-rebuild; then
    typeset -r nix_bin="$(command -v nix)"
    local darwin_config

    if darwin_config="$("$SCRIPTS_DIR/home-manager-host.sh" current-config 2>/dev/null)"; then
      :
    else
      darwin_config="$("$SCRIPTS_DIR/home-manager-host.sh" current-name)"
    fi

    sudo -H "$nix_bin" run nix-darwin#darwin-rebuild -- switch --flake "path:$DOTFILE_DIR#$darwin_config"
    remove_bootstrap_dotfiles || warn "nix-darwin applied but bootstrap dotfile cleanup failed"
  fi
}

maybe_apply_home_manager() {
  if is-installed nix && is-linux && [[ "${USE_HOME_MANAGER:-0}" == "1" ]]; then
    "$SCRIPTS_DIR/apply-home-manager.sh" "${HOME_MANAGER_CONFIG:-}"
  fi
}

ensure_shell_directories
ensure_ssh_directory
migrate_claude_config
ensure_git_safe_directory
update_git_submodules
ensure_nix_installed
load_nix_environment
ensure_homebrew
install_dotfiles
configure_macos_defaults
ensure_nix_darwin
maybe_apply_home_manager
