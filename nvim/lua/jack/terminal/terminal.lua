-- Terminal Plugin
--
-- A flexible terminal management plugin for Neovim that supports both floating
-- and split terminal windows with advanced configuration options.

local M = {}

-- A variable to hold the terminal window ID. We initialize it to nil.
local terminal_win_id = nil
-- A new variable to hold the terminal buffer ID. This will persist.
local terminal_buf_id = nil

--- Creates and configures a new terminal buffer.
--- @return number The created buffer ID
local function create_terminal_buffer()
  local buf_id = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_option(buf_id, "buflisted", false)
  vim.api.nvim_buf_set_option(buf_id, "bufhidden", "wipe")
  return buf_id
end

--- Creates a split window with the specified configuration.
--- @param buf_id number The buffer ID to set in the new window
--- @param window_config table|nil Configuration for the split window
--- @return number The created window ID
local function create_split_window(buf_id, window_config)
  local config = window_config or {}
  local split_direction = config.split_direction or "vertical"

  if split_direction == "horizontal" then
    vim.cmd("split")
  else
    vim.cmd("vsplit")
  end

  vim.api.nvim_win_set_buf(0, buf_id)
  local win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_option(win_id, "winbar", "")
  return win_id
end

--- Creates a terminal window with the specified configuration.
--- Routes to appropriate window creation method based on window type.
--- @param buf_id number The buffer ID to display
--- @param window_config table|nil Configuration for window creation
--- @return number The created window ID
local function create_terminal_window(buf_id, window_config)
  local config = window_config or {}
  local window_type = config.type or "split"

  if window_type == "float" then
    return create_float_window(buf_id, config)
  else
    return create_split_window(buf_id, config)
  end
end

--- Starts terminal in buffer and configures it.
--- @param buf_id number The buffer ID
--- @param win_id number The window ID
--- @param cmd string|nil Optional command to run in terminal
--- @param close_on_exit boolean|nil Whether to close terminal when command exits (default: false)
local function configure_terminal(buf_id, win_id, cmd, close_on_exit)
  if cmd then
    if close_on_exit then
      -- Run command and exit when done
      vim.cmd.terminal(cmd)
    else
      -- Run command but keep terminal open with shell afterwards
      local shell = vim.o.shell
      local full_cmd = cmd .. "; " .. shell
      vim.cmd.terminal(full_cmd)
    end
  else
    vim.cmd.terminal()
  end
  vim.api.nvim_buf_set_option(buf_id, "filetype", "terminal")
  -- Ensure winbar is cleared after terminal setup
  vim.api.nvim_win_set_option(win_id, "winbar", "")
  vim.cmd.startinsert()
end

--- Calculates floating window dimensions and positions.
--- @param width number|string Width (absolute or percentage 0.0-1.0)
--- @param height number|string Height (absolute or percentage 0.0-1.0)
--- @param row number|string Row position (absolute or "center")
--- @param col number|string Column position (absolute or "center")
--- @return table Table with width, height, row, col as absolute values
local function calculate_float_dimensions(width, height, row, col)
  local screen_width = vim.o.columns
  local screen_height = vim.o.lines

  -- Validate and convert width
  local abs_width = width
  if type(width) == "number" then
    if width > 0 and width <= 1 then
      abs_width = math.floor(screen_width * width)
    elseif width <= 0 or width > screen_width then
      error("Invalid width: must be between 1 and " .. screen_width .. " or between 0.0 and 1.0 for percentage")
    end
  else
    error("Width must be a number")
  end

  -- Validate and convert height
  local abs_height = height
  if type(height) == "number" then
    if height > 0 and height <= 1 then
      abs_height = math.floor(screen_height * height)
    elseif height <= 0 or height > screen_height then
      error("Invalid height: must be between 1 and " .. screen_height .. " or between 0.0 and 1.0 for percentage")
    end
  else
    error("Height must be a number")
  end

  -- Validate and convert positions
  local abs_row = row
  local abs_col = col

  if row == "center" then
    abs_row = math.floor((screen_height - abs_height) / 2)
  elseif type(row) == "number" then
    if row < 0 or row >= screen_height then
      error("Invalid row position: must be between 0 and " .. (screen_height - 1) .. " or 'center'")
    end
  else
    error("Row must be a number or 'center'")
  end

  if col == "center" then
    abs_col = math.floor((screen_width - abs_width) / 2)
  elseif type(col) == "number" then
    if col < 0 or col >= screen_width then
      error("Invalid col position: must be between 0 and " .. (screen_width - 1) .. " or 'center'")
    end
  else
    error("Column must be a number or 'center'")
  end

  return {
    width = abs_width,
    height = abs_height,
    row = abs_row,
    col = abs_col,
  }
end

--- Creates a floating window with the specified configuration.
--- @param buf_id number The buffer ID to display in the floating window
--- @param window_config table Configuration for the floating window
--- @return number The created window ID
local function create_float_window(buf_id, window_config)
  -- Set defaults
  local config = {
    width = window_config.width or 80,
    height = window_config.height or 24,
    row = window_config.row or "center",
    col = window_config.col or "center",
    border = window_config.border or "rounded",
    title = window_config.title,
  }

  -- Calculate absolute dimensions and positions
  local dimensions = calculate_float_dimensions(config.width, config.height, config.row, config.col)

  -- Create floating window configuration
  local float_opts = {
    relative = "editor",
    width = dimensions.width,
    height = dimensions.height,
    row = dimensions.row,
    col = dimensions.col,
    style = "minimal",
    border = config.border,
  }

  -- Add title if specified
  if config.title then
    float_opts.title = config.title
    float_opts.title_pos = "center"
  end

  -- Create the floating window
  local win_id = vim.api.nvim_open_win(buf_id, true, float_opts)
  vim.api.nvim_win_set_option(win_id, "winbar", "")

  return win_id
end

--- Toggles the visibility of the terminal window.
--- If the window exists, it closes it. If it doesn't, it creates or reopens one.
function M.toggle_side_terminal()
  -- Check if the terminal window is currently open.
  if terminal_win_id and vim.api.nvim_win_is_valid(terminal_win_id) then
    -- The window is open, so we close it. The buffer remains.
    vim.api.nvim_win_close(terminal_win_id, true)
    terminal_win_id = nil
    -- Check if the terminal buffer exists and is valid.
  elseif terminal_buf_id and vim.api.nvim_buf_is_valid(terminal_buf_id) then
    -- The window is closed, but the buffer exists, so we reopen the window in a vertical split.
    terminal_win_id = create_terminal_window(terminal_buf_id, { type = "split" })
    vim.cmd.startinsert()
  else
    -- This is the first time. Create the buffer and the window.
    terminal_buf_id = create_terminal_buffer()
    terminal_win_id = create_terminal_window(terminal_buf_id, { type = "split" })
    configure_terminal(terminal_buf_id, terminal_win_id, nil, false)
  end
end

--- Creates a new custom terminal with the specified command.
--- @param config table Configuration table with cmd field and optional window config
--- @return table Table with buf_id and win_id of the created terminal
function M.create_custom_terminal(config)
  -- Validate input
  if not config or not config.cmd then
    error("create_custom_terminal requires config table with cmd field")
  end

  -- Create a new buffer for the custom terminal
  local custom_buf_id = create_terminal_buffer()

  -- Create the terminal window with specified configuration
  local custom_win_id = create_terminal_window(custom_buf_id, config.window)

  -- Start the terminal with the specified command
  configure_terminal(custom_buf_id, custom_win_id, config.cmd, config.close_on_exit)

  -- Return the buffer and window IDs for caller management
  return {
    buf_id = custom_buf_id,
    win_id = custom_win_id,
  }
end

--- Creates a floating terminal window with a new buffer.
--- Exposed for external use.
--- @param config table Configuration for the floating terminal:
---   - cmd: string|nil - Optional command to run in terminal (e.g., "htop", "bash")
---   - close_on_exit: boolean|nil - Whether to close terminal when command exits (default: false)
---   - window: table - Window configuration:
---     - width: number - Window width in columns OR percentage (0.0-1.0 for screen percentage)
---     - height: number - Window height in rows OR percentage (0.0-1.0 for screen percentage)
---     - row: number|"center" - Window row position (0-based) or "center" for auto-centering
---     - col: number|"center" - Window column position (0-based) or "center" for auto-centering
---     - border: string - Border style: "none", "single", "double", "rounded", "solid", "shadow" (default: "rounded")
---     - title: string|nil - Optional window title (displayed in border)
--- @return table Table with buf_id and win_id of the created floating terminal
---
--- Examples:
---   -- 80% screen width, 60% height, centered
---   create_floating_terminal({ 
---     window = { width = 0.8, height = 0.6, row = "center", col = "center" }
---   })
---
---   -- Fixed size 100x30, positioned at row 5, col 10, with htop command (stays open after htop exits)
---   create_floating_terminal({ 
---     cmd = "htop",
---     window = { width = 100, height = 30, row = 5, col = 10 }
---   })
---
---   -- Run command and close terminal when it finishes
---   create_floating_terminal({
---     cmd = "ls -la",
---     close_on_exit = true,
---     window = { width = 0.8, height = 0.6, row = "center", col = "center" }
---   })
---
---   -- Centered window with title, custom border, and bash command
---   create_floating_terminal({
---     cmd = "bash",
---     window = {
---       width = 0.9, height = 0.7, row = "center", col = "center",
---       border = "double", title = "Development Terminal"
---     }
---   })
function M.create_floating_terminal(config)
  config = config or {}
  local buf_id = create_terminal_buffer()
  local win_id = create_float_window(buf_id, config.window or {})
  configure_terminal(buf_id, win_id, config.cmd, config.close_on_exit)
  -- Ensure the cursor is in the floating terminal window
  vim.api.nvim_set_current_win(win_id)
  return {
    buf_id = buf_id,
    win_id = win_id,
  }
end

--- Toggles the visibility of a floating terminal window.
--- If the window is open, closes it. If closed but buffer exists, reopens it.
--- @param terminal_info table The table returned by create_floating_terminal with buf_id and win_id
--- @param window_config table|nil Optional window configuration for reopening (uses defaults if not provided)
--- @return table Updated terminal_info with current win_id (nil if closed)
---
--- Example:
---   local my_terminal = create_floating_terminal({ 
---     window = { width = 0.8, height = 0.6, row = "center", col = "center" }
---   })
---   -- Later toggle it on/off:
---   my_terminal = toggle_floating_terminal(my_terminal, { width = 0.8, height = 0.6 })
function M.toggle_floating_terminal(terminal_info, window_config)
  if not terminal_info or not terminal_info.buf_id then
    error("toggle_floating_terminal requires terminal_info with buf_id")
  end
  
  -- Check if the window is currently open and valid
  if terminal_info.win_id and vim.api.nvim_win_is_valid(terminal_info.win_id) then
    -- Window is open, close it
    vim.api.nvim_win_close(terminal_info.win_id, true)
    terminal_info.win_id = nil
  else
    -- Window is closed, check if buffer is still valid
    if vim.api.nvim_buf_is_valid(terminal_info.buf_id) then
      -- Buffer exists, reopen the floating window
      local config = window_config or {
        width = 0.8,
        height = 0.6,
        row = "center",
        col = "center",
        border = "rounded"
      }
      terminal_info.win_id = create_float_window(terminal_info.buf_id, config)
      vim.api.nvim_set_current_win(terminal_info.win_id)
      vim.cmd.startinsert()
    else
      error("Terminal buffer is no longer valid")
    end
  end
  
  return terminal_info
end

-- A setup function to be called from init.lua to set up the keymap.
function M.setup()
  vim.keymap.set("n", "<leader>pp", M.toggle_side_terminal, { noremap = true, silent = true })
end

return M