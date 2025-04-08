local snipe = require("snipe")

local M = {}
M.setup = function()
  snipe.setup({
    -- Add your custom configuration here
    -- For example:
    -- mappings = {
    --   ["<leader>sn"] = "snipe",
    -- },
  })
  vim.keymap.set("n", "<leader><leader>", function()
    snipe.open_buffer_menu()
  end, { desc = "Snipe" })
end

return M
