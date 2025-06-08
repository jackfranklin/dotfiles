local goose_api = require("goose.api")
require("goose").setup({
  default_global_keymaps = false,
})

vim.keymap.set("n", "<leader>oo", goose_api.toggle, {
  desc = "[Goose] Toggle",
})

vim.keymap.set("n", "<leader>oi", goose_api.open_input, {
  desc = "[Goose] Focus Input",
})

vim.keymap.set("n", "<leader>od", goose_api.diff_open, {
  desc = "[Goose] Diff",
})
