require("executor").setup({
  use_split = false,
})
vim.api.nvim_set_keymap("n", "<leader>er", ":ExecutorRun<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>ev", ":ExecutorToggleDetail<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>es", ":ExecutorSetCommand<CR>", {})
