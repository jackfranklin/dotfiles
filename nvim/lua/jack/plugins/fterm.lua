local M = {}
M.setup = function(config)
  local width = config.width or 0.4
  local height = config.height or 0.8

  require("FTerm").setup({
    dimensions = {
      width = width,
      height = height,
      y = vim.o.lines,
      x = vim.o.columns,
    },
    border = "double",
  })
end

return M
