#!/usr/bin/env zsh
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd -P)/lib/logging.sh"

legacy_dir="$HOME/.claude"
# Shipped config: stow links it under $HOME/.config whatever XDG_CONFIG_HOME says.
config_dir="$HOME/.config/claude"

if [[ -L "$legacy_dir" ]]; then
  info "$legacy_dir is already a symlink. Leaving it unchanged."
  exit 0
fi

if [[ ! -e "$legacy_dir" ]]; then
  if [[ -d "$config_dir" ]]; then
    ln -s "$config_dir" "$legacy_dir"
    success "Linked $legacy_dir -> $config_dir"
  else
    info "No legacy Claude directory found at $legacy_dir. Nothing to migrate."
  fi
  exit 0
fi

if [[ ! -d "$legacy_dir" ]]; then
  warn "$legacy_dir exists but is not a directory. Skipping migration."
  exit 0
fi

# dotsync runs this after linking, so $config_dir is a real dir holding
# per-file stow links. Anything else means stow has not run, or linked the
# dir whole into the repo: merging would block stow or write into the repo.
if [[ -L "$config_dir" || ! -d "$config_dir" ]]; then
  error "$config_dir is not a real dir. Remove it if it is a link, then rerun dotsync."
  exit 1
fi

# Shipped entries win and are never descended into: a stow link stays a link.
# Legacy entries already in $config_dir stay in the backup under XDG_STATE_HOME.
backup_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude-migrate/$(date +%Y%m%d%H%M%S)"
mkdir -p -- "${backup_dir:h}"
kept=()
for entry in "$legacy_dir"/*(DN); do
  if [[ -e "$config_dir/${entry:t}" || -L "$config_dir/${entry:t}" ]]; then
    kept+=("${entry:t}")
  else
    mv -- "$entry" "$config_dir/"
  fi
done
mv -- "$legacy_dir" "$backup_dir"
ln -s "$config_dir" "$legacy_dir"
success "Merged $legacy_dir into $config_dir and created compatibility symlink."
if (( ${#kept} )); then
  warn "Already in $config_dir, so left in $backup_dir: ${kept[*]}"
fi
