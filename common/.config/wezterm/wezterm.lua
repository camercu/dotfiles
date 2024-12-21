-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices:

config.font = wezterm.font("MesloLGS Nerd Font")
config.color_scheme = "Catppuccin Macchiato (Gogh)"
config.hide_tab_bar_if_only_one_tab = true

-- Must return config as last line
return config
