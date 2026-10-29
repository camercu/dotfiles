# XDG base dirs, plus BIN and LIB extensions.
# ref: https://specifications.freedesktop.org/basedir/latest/
# The other env/*.sh files fall back to the same defaults, so load order
# does not matter.
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_LIB_HOME="$HOME/.local/lib"
export XDG_STATE_HOME="$HOME/.local/state"
