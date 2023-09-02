local map = vim.keymap.set
map("n", "m", function()
  require("pounce").pounce({})
end)
