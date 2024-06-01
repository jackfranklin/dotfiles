-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

local has_custom_config, custom_config = pcall(require, "per_machine")

local config = {}

config.color_scheme = has_custom_config and custom_config.color_scheme or "Kanagawa (Gogh)"

config.colors = {
  -- ENABLE ME if using Kanagawa (default cursor is too bright for me)
  -- cursor_bg = "#787669",
  -- ENABLE ME if using Darkside
  -- cursor_bg = "#787669",
}
config.use_fancy_tab_bar = false
config.tab_max_width = 32

local is_wsl = has_custom_config and custom_config.is_wsl == true
if is_wsl then
  config.default_prog = { "C:\\Windows\\System32\\wsl.exe" }
  config.default_domain = "WSL:Ubuntu"
end

-- config.font = wezterm.font("IntelOne Mono")
-- config.font = wezterm.font("Comic Code")
-- config.font = wezterm.font("Hack")
-- config.font = wezterm.font("Victor Mono")
-- config.font = wezterm.font("DM Mono")
config.font = wezterm.font("Berkeley Mono")
-- config.font = wezterm.font("Geist Mono")
-- Disable ligatures.
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

config.font_size = has_custom_config and custom_config.font_size or 15
config.window_padding = {
  left = 0,
  right = 0,
  bottom = 0,
  top = 0,
}

config.window_decorations = "RESIZE"

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
