-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- For example, changing the color scheme:
config.color_scheme = "Catppuccin Frappe"
config.default_prog = { "C:\\Windows\\System32\\wsl.exe" }
config.font = wezterm.font("IntelOne Mono")
config.font_size = 14

config.keys = {
  {
    key = "r",
    mods = "CMD|SHIFT",
    action = wezterm.action.ReloadConfiguration,
  },
}

-- and finally, return the configuration to wezterm
return config
