local M = {}

M.setup = function()
  local alt = require("alternate-files")

  alt.setup({
    only_existing = true,
    patterns = {
      { ".test.ts", { ".ts" } },
      { ".ts", { ".test.ts", ".css" } },
      { ".css", { ".ts" } },
    },
  })

  vim.keymap.set("n", "<leader>fa", function()
    alt.jump()
  end, { desc = "Jump to the [A]lternate file" })
end

return M
