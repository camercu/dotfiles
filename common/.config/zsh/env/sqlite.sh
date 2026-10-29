# Directly in XDG_STATE_HOME: sqlite3 does not create a missing parent dir.
export SQLITE_HISTORY="${XDG_STATE_HOME:-$HOME/.local/state}/sqlite_history"
