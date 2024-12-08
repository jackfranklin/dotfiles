vim.g.rg_command = 'rg --vimgrep --smart-case -g "!node_modules/" -g "!locales/" '
vim.keymap.set("n", "<leader>/", ":Rg<Space>", { desc = "Search with Rg!" })
