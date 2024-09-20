local M = {}

M.setup = function()
  require("supermaven-nvim").setup({
    ignore_filetypes = {
      gitcommit = true,
    },
  })
end

return M
