require("harpoon").setup({
  menu = {
    width = math.floor(vim.api.nvim_win_get_width(0) * 4 / 5),
  },
})

vim.keymap.set({ "n" }, "<leader>ha", function()
  require("harpoon.mark").add_file()
end)

vim.keymap.set({ "n" }, "<leader>hr", function()
  require("harpoon.mark").rm_file()
end)

vim.keymap.set({ "n" }, "<leader>hq", function()
  require("harpoon.mark").clear_all()
end)

vim.keymap.set({ "n" }, "<leader>hl", function()
  require("harpoon.ui").toggle_quick_menu()
end)

vim.keymap.set({ "n" }, "<leader>hn", function()
  require("harpoon.ui").nav_next()
end)

vim.keymap.set({ "n" }, "<leader>hp", function()
  require("harpoon.ui").nav_prev()
end)
