local M = {}

M.setup = function()
  local hop = require("hop")
  local directions = require("hop.hint").HintDirection

  hop.setup({
    -- This is the default set of keys as suggested in the README
    keys = "etovxqpdygfblzhckisuran",
  })

  vim.keymap.set("n", "<leader>hw", function()
    hop.hint_words({ direction = directions.AFTER_CURSOR })
  end, { desc = "[h]op [w]ord forwards" })
  vim.keymap.set("n", "<leader>hW", function()
    hop.hint_words({ direction = directions.BEFORE_CURSOR })
  end, { desc = "[h]op [W]ord backwards" })
end

return M
