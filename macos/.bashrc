# Bash has no XDG location for its rc file, so this one stays in $HOME.
# Claude Code runs commands in bash (CLAUDE_CODE_SHELL): give it the same tool
# locations zsh gets from .zshenv, so tools it runs keep out of $HOME too.
for _f in "${XDG_CONFIG_HOME:-$HOME/.config}"/zsh/env/*.sh; do
  [ -r "$_f" ] && . "$_f"
done
unset _f
