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

mkdir -p -- "${config_dir:h}"

if [[ ! -e "$config_dir" ]]; then
  mv -- "$legacy_dir" "$config_dir"
  ln -s "$config_dir" "$legacy_dir"
  success "Migrated $legacy_dir to $config_dir and created compatibility symlink."
  exit 0
fi

if [[ ! -d "$config_dir" ]]; then
  warn "$config_dir exists but is not a directory. Skipping migration."
  exit 0
fi

# Never replace a stow link, nor write through a dir linked whole into the
# repo.
if [[ -L "$config_dir" ]]; then
  error "$config_dir links into the repo. Merge $legacy_dir into it by hand."
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
