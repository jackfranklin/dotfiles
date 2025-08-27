vim.g.rg_command = "rg --vimgrep --smart-case "
vim.keymap.set("n", "<leader>/", ":Rg<Space>", { desc = "Search with Rg!" })
