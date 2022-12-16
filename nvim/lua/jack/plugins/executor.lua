M = {}

M.setup = function(config)
  require("executor").setup({
    use_split = false,
    popup = {
      height = vim.o.lines - 10,
    },
    output_filter = function(command, lines)
      if config.output_filter then
        return config.output_filter(command, lines)
      else
        return lines
      end
    end,
  })
  vim.api.nvim_set_keymap("n", "<leader>er", ":ExecutorRun<CR>", {})
  vim.api.nvim_set_keymap("n", "<leader>ev", ":ExecutorToggleDetail<CR>", {})
  vim.api.nvim_set_keymap("n", "<leader>es", ":ExecutorSetCommand<CR>", {})
end

return M