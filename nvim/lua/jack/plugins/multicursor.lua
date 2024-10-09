local mc = require("multicursor-nvim")

mc.setup()

local set = vim.keymap.set

-- Add or skip cursor above/below the main cursor.
set({ "n", "v" }, "<up>", function()
  mc.lineAddCursor(-1)
end)
set({ "n", "v" }, "<down>", function()
  mc.lineAddCursor(1)
end)

-- Add or skip adding a new cursor by matching word/selection
set({ "n", "v" }, "<leader>xn", function()
  mc.matchAddCursor(1)
end)
set({ "n", "v" }, "<leader>s", function()
  mc.matchSkipCursor(1)
end)
set({ "n", "v" }, "<leader>N", function()
  mc.matchAddCursor(-1)
end)
set({ "n", "v" }, "<leader>S", function()
  mc.matchSkipCursor(-1)
end)

set("n", "<esc>", function()
  if not mc.cursorsEnabled() then
    mc.enableCursors()
  elseif mc.hasCursors() then
    mc.clearCursors()
  else -- Default esc behaviour for me : clear the search as well.
    vim.api.nvim_exec2([[noh]], { output = false })
  end
end)
