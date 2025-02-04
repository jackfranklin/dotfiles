local M = {}
M.setup = function()
  local magenta = require("magenta")
  magenta.setup({
    sidebar_position = "right",
  })
end
return M
