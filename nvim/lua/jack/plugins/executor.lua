local M = {}

M.setup = function(config)
  local preset_commands = {
    ["executor.nvim"] = {
      "make test",
    },
    ["routemaster"] = {
      { partial = true, cmd = 'make tests-with-glob GLOB="test/' },
      "npm run build-run-tests",
      "npm run build-run-tests-esbuild",
      "npm run typecheck",
      "npm run check-lint",
    },
  }
  local merged_preset_commands = vim.tbl_deep_extend("force", preset_commands, config.preset_commands or {})

  require("executor").setup({
    use_split = false,
    notifications = {
      task_started = false,
      task_completed = false,
    },
    popup = {
      height = vim.o.lines - 10,
    },
    preset_commands = merged_preset_commands,
    output_filter = function(command, lines)
      if config.output_filter then
        return config.output_filter(command, lines)
      else
        return lines
      end
    end,
    statusline = {
      prefix_text = "",
      icons = {
        failed = "F",
        passed = "P",
      },
    },
  })
  local opts = { noremap = true, silent = true }
  vim.api.nvim_set_keymap("n", "<leader>er", ":ExecutorRun<CR>", opts)
  vim.api.nvim_set_keymap("n", "<leader>ev", ":ExecutorToggleDetail<CR>", opts)
  vim.api.nvim_set_keymap("n", "<leader>es", ":ExecutorSetCommand<CR>", opts)
  vim.api.nvim_set_keymap("n", "<leader>ep", ":ExecutorShowPresets<CR>", opts)
  vim.api.nvim_set_keymap("n", "<leader>eh", ":ExecutorShowHistory<CR>", opts)
end

return M
