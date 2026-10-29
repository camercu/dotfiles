# omp: config root is $HOME joined with PI_CONFIG_DIR (relative path), so
# ~/.config/omp. Data, state, and cache go under $XDG_*_HOME/omp because those
# dirs exist (`omp config init-xdg`). PI_CONFIG_FILES layers the tracked
# settings over the config.yml omp rewrites.
export PI_CONFIG_DIR=.config/omp
export PI_CONFIG_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/agents/omp.yml"
