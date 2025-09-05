-- Terminal Toggle Plugin
--
-- This module creates a terminal buffer in a vertical split.
-- It can be toggled on and off with a simple function call, and the terminal state is
-- persisted between toggles.

local M = {}

-- A variable to hold the terminal window ID. We initialize it to nil.
local terminal_win_id = nil
-- A new variable to hold the terminal buffer ID. This will persist.
local terminal_buf_id = nil

--- Toggles the visibility of the terminal window.
--- If the window exists, it closes it. If it doesn't, it creates or reopens one.
function M.toggle_terminal()
  -- Check if the terminal window is currently open.
  if terminal_win_id and vim.api.nvim_win_is_valid(terminal_win_id) then
    -- The window is open, so we close it. The buffer remains.
    vim.api.nvim_win_close(terminal_win_id, true)
    terminal_win_id = nil
    -- Check if the terminal buffer exists and is valid.
  elseif terminal_buf_id and vim.api.nvim_buf_is_valid(terminal_buf_id) then
    -- The window is closed, but the buffer exists, so we reopen the window in a vertical split.
    vim.cmd("vsplit")
    vim.api.nvim_win_set_buf(0, terminal_buf_id)
    terminal_win_id = vim.api.nvim_get_current_win()
    vim.cmd.startinsert()
  else
    -- This is the first time. Create the buffer and the window.
    terminal_buf_id = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_option(terminal_buf_id, "buflisted", false)
    vim.api.nvim_buf_set_option(terminal_buf_id, "bufhidden", "wipe")

    -- Create a vertical split and set the buffer.
    vim.cmd("vsplit")
    vim.api.nvim_win_set_buf(0, terminal_buf_id)
    terminal_win_id = vim.api.nvim_get_current_win()

    -- Start the terminal and enter insert mode.
    vim.cmd.terminal()
    vim.api.nvim_buf_set_option(terminal_buf_id, "filetype", "terminal")
    vim.api.nvim_win_set_option(terminal_win_id, "winbar", "")
    vim.cmd.startinsert()
  end
end

-- A setup function to be called from init.lua to set up the keymap.
function M.setup()
  vim.keymap.set("n", "<leader>pp", M.toggle_terminal, { noremap = true, silent = true })
end

return M
