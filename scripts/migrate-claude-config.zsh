#!/usr/bin/env zsh
set -euo pipefail

: "${XDG_CONFIG_HOME:=$HOME/.config}"

legacy_dir="${CLAUDE_LEGACY_DIR:-$HOME/.claude}"
xdg_dir="${CLAUDE_XDG_DIR:-$XDG_CONFIG_HOME/claude}"
xdg_parent="${xdg_dir:h}"

if [[ -L "$legacy_dir" ]]; then
  echo "[*] $legacy_dir is already a symlink. Leaving it unchanged."
  exit 0
fi

if [[ ! -e "$legacy_dir" ]]; then
  if [[ -d "$xdg_dir" ]]; then
    ln -s "$xdg_dir" "$legacy_dir"
    echo "[+] Linked $legacy_dir -> $xdg_dir"
  else
    echo "[*] No legacy Claude directory found at $legacy_dir. Nothing to migrate."
  fi
  exit 0
fi

if [[ ! -d "$legacy_dir" ]]; then
  echo "[!] $legacy_dir exists but is not a directory. Skipping migration."
  exit 0
fi

mkdir -p -- "$xdg_parent"

if [[ ! -e "$xdg_dir" ]]; then
  mv -- "$legacy_dir" "$xdg_dir"
  ln -s "$xdg_dir" "$legacy_dir"
  echo "[+] Migrated $legacy_dir to $xdg_dir and created compatibility symlink."
  exit 0
fi

if [[ ! -d "$xdg_dir" ]]; then
  echo "[!] $xdg_dir exists but is not a directory. Skipping migration."
  exit 0
fi

if command -v rsync >/dev/null 2>&1; then
  rsync -a -- "$legacy_dir"/ "$xdg_dir"/
  rm -rf -- "$legacy_dir"
  ln -s "$xdg_dir" "$legacy_dir"
  echo "[+] Merged $legacy_dir into $xdg_dir and created compatibility symlink."
  exit 0
fi

backup_dir="${legacy_dir}.backup.$(date +%Y%m%d%H%M%S)"
mv -- "$legacy_dir" "$backup_dir"
ln -s "$xdg_dir" "$legacy_dir"
echo "[!] rsync is not available."
echo "[!] Moved legacy directory to $backup_dir."
echo "[!] Merge its contents into $xdg_dir manually if needed."
