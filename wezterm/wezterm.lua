-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This table will hold the configuration.
local config = {}

-- For example, changing the color scheme:
-- config.color_scheme = "Catppuccin Frappe"
-- config.color_scheme = "Darkside"
-- config.color_scheme = "Darktooth (base16)"
-- config.color_scheme = "deep"
-- config.color_scheme = "Tokyo Night"
config.color_scheme = "Kanagawa (Gogh)"

config.colors = {
  -- ENABLE ME if using Kanagawa (default cursor is too bright for me)
  cursor_bg = "#787669",
  -- ENABLE ME if using Darkside
  -- cursor_bg = "#787669",
}
config.default_prog = { "C:\\Windows\\System32\\wsl.exe" }
config.default_domain = "WSL:Ubuntu"
-- config.font = wezterm.font("IntelOne Mono")
-- config.font = wezterm.font("Comic Code")
-- config.font = wezterm.font("Hack")
-- config.font = wezterm.font("Victor Mono")
-- config.font = wezterm.font("DM Mono")
config.font = wezterm.font("Geist Mono")
-- Disable ligatures.
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

config.font_size = 16
config.window_padding = {
  left = 0,
  right = 0,
  bottom = 0,
  top = 0,
}

config.keys = {
  -- Shift + Control + R to rename tab
  {
    key = "R",
    mods = "SHIFT|CTRL",
    action = act.PromptInputLine({
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
}

-- and finally, return the configuration to wezterm
return config
