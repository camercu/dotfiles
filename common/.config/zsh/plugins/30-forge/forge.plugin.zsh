# If _FORGE_BIN is unset the previous eval didn't fully initialise —
# exec zsh re-inherits _FORGE_PLUGIN_LOADED from the old process. Force reload.
[[ -n "$_FORGE_PLUGIN_LOADED" && -z "$_FORGE_BIN" ]] && unset _FORGE_PLUGIN_LOADED

if (( $+commands[forge] )); then
  [[ -z "$_FORGE_PLUGIN_LOADED" ]] && eval "$(forge zsh plugin)"
  [[ -z "$_FORGE_THEME_LOADED"  ]] && eval "$(forge zsh theme)"
fi
