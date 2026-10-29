# Bash has no XDG location for its rc file, so this one stays in $HOME.
# Interactive bash gets the same tool locations zsh gets from .zshenv. Claude
# Code's shell snapshot drops these exports; its SessionStart hook in
# settings.json feeds the same files through CLAUDE_ENV_FILE.
for _f in "${XDG_CONFIG_HOME:-$HOME/.config}"/zsh/env/*.sh; do
  # shellcheck source=/dev/null # per-tool exports, linted on their own
  [ -r "$_f" ] && . "$_f"
done
unset _f
