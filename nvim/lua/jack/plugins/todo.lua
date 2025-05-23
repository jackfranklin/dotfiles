require("todo-comments").setup({
  signs = false,
  highlight = {
    keyword = "bg",
    after = "", -- disable highlighting of the comment other than the keyword
  },
})
vim.keymap.set("n", "<leader>xt", ":TodoFzfLua<CR>", { desc = "Search for TODOs with FzfLua" })
vim.keymap.set("n", "<leader>xl", ":TodoQuickFix<CR>", { desc = "List TODOs in QF" })
