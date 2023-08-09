local map = vim.keymap.set
map("n", "<leader>q", function()
  require("pounce").pounce({})
end)
