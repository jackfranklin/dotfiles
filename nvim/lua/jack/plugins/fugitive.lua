vim.api.nvim_set_keymap("n", "<leader>gs", ":tab G<CR>", { desc = "[g]it [s]tatus" })
vim.api.nvim_set_keymap("n", "<leader>gc", ":Git checkout -b ", { desc = "[g]it [c]heckout -b <>" })
vim.api.nvim_set_keymap("n", "<leader>gp", ":Git push", { desc = "[g]it [p]ush" })
