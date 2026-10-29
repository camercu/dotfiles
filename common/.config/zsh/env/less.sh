# Directly in XDG_STATE_HOME: less does not create a missing parent dir.
export LESSHISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/lesshst"
