local M = {}

M.setup = function()
  require("supermaven-nvim").setup({
    keymaps = {
      clear_suggestion = "<C-q>",
      accept_word = "<C-a>",
    },
    ignore_filetypes = {
      gitcommit = true,
    },
  })
end

return M
