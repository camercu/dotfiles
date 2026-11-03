#!/usr/bin/env zsh
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd -P)/lib/logging.sh"

legacy_dir="${CLAUDE_LEGACY_DIR:-$HOME/.claude}"
# Shipped config: stow links it under $HOME/.config whatever XDG_CONFIG_HOME says.
xdg_dir="${CLAUDE_XDG_DIR:-$HOME/.config/claude}"
xdg_parent="${xdg_dir:h}"

if [[ -L "$legacy_dir" ]]; then
  info "$legacy_dir is already a symlink. Leaving it unchanged."
  exit 0
fi

if [[ ! -e "$legacy_dir" ]]; then
  if [[ -d "$xdg_dir" ]]; then
    ln -s "$xdg_dir" "$legacy_dir"
    success "Linked $legacy_dir -> $xdg_dir"
  else
    info "No legacy Claude directory found at $legacy_dir. Nothing to migrate."
  fi
  exit 0
fi

if [[ ! -d "$legacy_dir" ]]; then
  warn "$legacy_dir exists but is not a directory. Skipping migration."
  exit 0
fi

mkdir -p -- "$xdg_parent"

if [[ ! -e "$xdg_dir" ]]; then
  mv -- "$legacy_dir" "$xdg_dir"
  ln -s "$xdg_dir" "$legacy_dir"
  success "Migrated $legacy_dir to $xdg_dir and created compatibility symlink."
  exit 0
fi

if [[ ! -d "$xdg_dir" ]]; then
  warn "$xdg_dir exists but is not a directory. Skipping migration."
  exit 0
fi

# Never replace a stow link, nor write through a dir linked whole into the
# repo.
if [[ -L "$xdg_dir" ]]; then
  error "$xdg_dir links into the repo. Merge $legacy_dir into it by hand."
  exit 1
fi

# Shipped entries win and are never descended into: a stow link stays a link.
# Legacy entries already in $xdg_dir stay in the backup under XDG_STATE_HOME.
backup_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude-migrate/$(date +%Y%m%d%H%M%S)"
mkdir -p -- "${backup_dir:h}"
kept=()
for entry in "$legacy_dir"/*(DN); do
  if [[ -e "$xdg_dir/${entry:t}" || -L "$xdg_dir/${entry:t}" ]]; then
    kept+=("${entry:t}")
  else
    mv -- "$entry" "$xdg_dir/"
  fi
done
mv -- "$legacy_dir" "$backup_dir"
ln -s "$xdg_dir" "$legacy_dir"
success "Merged $legacy_dir into $xdg_dir and created compatibility symlink."
if (( ${#kept} )); then
  warn "Already in $xdg_dir, so left in $backup_dir: ${kept[*]}"
fi
