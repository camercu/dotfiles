# Debian's skeleton ~/.bashrc sources this file, so linking it needs no change
# to a ~/.bashrc the host already owns. Same tool locations as zsh (.zshenv),
# then the shared aliases.
for _f in "${XDG_CONFIG_HOME:-$HOME/.config}"/zsh/env/*.sh; do
  # shellcheck source=/dev/null # per-tool exports, linted on their own
  [ -r "$_f" ] && . "$_f"
done
unset _f
# shellcheck source=../common/.config/sh/aliases.sh
. "${XDG_CONFIG_HOME:-$HOME/.config}/sh/aliases.sh"
