local M = {}

M.setup = function(config)
  local stored_commands = {
    ["executor.nvim"] = {
      "make test",
    },
  }
  local final_commands = vim.tbl_deep_extend("force", stored_commands, config.stored_commands or {})

  require("executor").setup({
    use_split = false,
    notifications = {
      task_started = false,
      task_completed = false,
    },
    popup = {
      height = vim.o.lines - 10,
    },
    stored_commands = final_commands,
    output_filter = function(command, lines)
      if config.output_filter then
        return config.output_filter(command, lines)
      else
        return lines
      end
    end,
  })
  local opts = { noremap = true, silent = true }
  vim.api.nvim_set_keymap("n", "<leader>er", ":ExecutorRun<CR>", opts)
  vim.api.nvim_set_keymap("n", "<leader>ev", ":ExecutorToggleDetail<CR>", opts)
  vim.api.nvim_set_keymap("n", "<leader>es", ":ExecutorSetCommand<CR>", opts)
end

return M
