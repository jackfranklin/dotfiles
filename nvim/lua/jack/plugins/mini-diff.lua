local diff = require("mini.diff")

diff.setup({})

vim.keymap.set("n", "<leader>gh", function()
  diff.toggle_overlay()
end)
