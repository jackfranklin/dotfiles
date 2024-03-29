local saga = require("lspsaga")

saga.setup({
  lightbulb = {
    enable = false,
  },
  definition = {
    height = 0.6,
    width = 0.6,
  },
  symbol_in_winbar = {
    enable = false,
  },
})

local opts = { noremap = true, silent = true }
