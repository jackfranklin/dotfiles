-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

local has_custom_config, custom_config = pcall(require, "per_machine")

local config = {}

config.color_scheme = has_custom_config and custom_config.color_scheme or "Mar (Gogh)"

config.colors = {
  -- ENABLE ME if using Kanagawa (default cursor is too bright for me)
  -- cursor_bg = "#787669",
  -- ENABLE ME if using Darkside
  -- cursor_bg = "#787669",
}
config.audible_bell = "Disabled"
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

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

local function make_new_tab_on_right_action(opts)
  local command = opts.command
  return wezterm.action_callback(function(window, pane)
    local mux_window = window:mux_window()
    local tabs = mux_window:tabs()
    local active_tab = window:active_tab()
    local active_tab_id = active_tab:tab_id()
    local current_idx = nil
    for i, t in ipairs(tabs) do
      if t:tab_id() == active_tab_id then
        current_idx = i - 1
        break
      end
    end

    local tab, new_pane, _ = mux_window:spawn_tab({})
    if command then
      new_pane:send_text(command .. "\n")
    end
    if current_idx then
      window:perform_action(wezterm.action.MoveTab(current_idx + 1), new_pane)
    end
  end)
end

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
  {
    -- Ctrl-M to make a new tab to the right of the current window
    key = "m",
    mods = "CTRL",
    action = wezterm.action_callback(function(window, pane)
      local mux_window = window:mux_window()

      -- determine the index of the current tab
      -- https://wezfurlong.org/wezterm/config/lua/mux-window/tabs_with_info.html
      local tabs = mux_window:tabs_with_info()
      local current_index = 0
      for _, tab_info in ipairs(tabs) do
        if tab_info.is_active then
          current_index = tab_info.index
          break
        end
      end

      -- spawn a new tab; it will be made active
      -- https://wezfurlong.org/wezterm/config/lua/mux-window/spawn_tab.html
      mux_window:spawn_tab({})

      -- Move the new active tab to the right of the previously active tab
      window:perform_action(act.MoveTab(current_index + 1), pane)
    end),
  },
  {
    key = "T",
    mods = "SHIFT|CTRL",
    action = make_new_tab_on_right_action({}),
  },
}

-- and finally, return the configuration to wezterm
return config
