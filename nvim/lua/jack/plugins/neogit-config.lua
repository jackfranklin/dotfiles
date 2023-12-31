local neogit = require("neogit")

neogit.setup({})

vim.keymap.set("n", "<leader>gv", function()
  neogit.open({ kind = "vsplit" })
end)
vim.keymap.set("n", "<leader>gt", function()
  neogit.open({ kind = "tab" })
end)
