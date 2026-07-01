#!/usr/bin/env zsh
set -eu
setopt pipefail

export DOTFILE_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"
typeset -r SCRIPTS_DIR="$DOTFILE_DIR/scripts"
typeset -r DOTSYNC_BIN="$DOTFILE_DIR/common/.local/bin/dotsync"

# load env vars (XDG_*, ZDOTDIR, ...) then the shared script helpers
builtin source "$DOTFILE_DIR/common/.zshenv"
builtin source "$SCRIPTS_DIR/lib/logging.sh"     # info/warn/error/success
builtin source "$SCRIPTS_DIR/lib/shell-lib.sh"   # is-macos/is-linux/is-admin/...

# run_step: announce a phase, then run it. Keeps the long bootstrap legible
# and shows where a failure happened.
run_step() {
  local label="$1"; shift
  info "==> ${label}"
  "$@"
}

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
  git submodule update --init --recursive
}

migrate_claude_config() {
  "$SCRIPTS_DIR/migrate-claude-config.zsh"
}

ensure_nix_installed() {
  is-installed nix && return 0
  is-macos || is-linux || return 0
  "$SCRIPTS_DIR/install-nix.sh"
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
  is-installed brew && return 0
  is-macos || return 0
  is-admin || return 0

  "$SCRIPTS_DIR/install-homebrew.sh"
  builtin eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_dotfiles() {
  "$DOTSYNC_BIN"
}

configure_macos_defaults() {
  is-macos || return 0
  "$SCRIPTS_DIR/config-macos.zsh"
}

ensure_nix_darwin() {
  is-macos || return 0
  is-admin || return 0
  is-installed darwin-rebuild && return 0

  typeset -r nix_bin="$(command -v nix)"
  local darwin_config
  darwin_config="$("$SCRIPTS_DIR/home-manager-host.sh" current-config 2>/dev/null)" \
    || darwin_config="$("$SCRIPTS_DIR/home-manager-host.sh" current-name)"

  sudo -H "$nix_bin" run nix-darwin#darwin-rebuild -- switch --flake "path:$DOTFILE_DIR#$darwin_config"
}

maybe_apply_home_manager() {
  is-installed nix || return 0
  is-linux || return 0
  [[ "${USE_HOME_MANAGER:-0}" == "1" ]] || return 0

  "$SCRIPTS_DIR/apply-home-manager.sh" "${HOME_MANAGER_CONFIG:-}"
}

main() {
  run_step "Creating shell directories"          ensure_shell_directories
  run_step "Ensuring ~/.ssh"                      ensure_ssh_directory
  run_step "Migrating Claude config"             migrate_claude_config
  run_step "Marking repo as git safe.directory"  ensure_git_safe_directory
  run_step "Updating git submodules"             update_git_submodules
  run_step "Installing Nix (if needed)"          ensure_nix_installed
  run_step "Loading Nix environment"             load_nix_environment
  run_step "Installing Homebrew (if needed)"     ensure_homebrew
  run_step "Linking dotfiles (stow)"             install_dotfiles
  run_step "Configuring macOS defaults"          configure_macos_defaults
  run_step "Applying nix-darwin (if needed)"     ensure_nix_darwin
  run_step "Applying home-manager (if enabled)"  maybe_apply_home_manager
  success "Bootstrap complete."
}

main "$@"
