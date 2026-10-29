# Directly in XDG_STATE_HOME: Python drops history silently when the parent
# dir is missing.
export PYTHON_HISTORY="${XDG_STATE_HOME:-$HOME/.local/state}/python_history"
