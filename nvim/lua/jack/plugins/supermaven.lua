local M = {}

M.setup = function()
  -- require("supermaven-nvim").setup({
  --   keymaps = {
  --     clear_suggestion = "<C-q>",
  --     accept_word = "<C-a>",
  --   },
  --   ignore_filetypes = {
  --     gitcommit = true,
  --   },
  --   condition = function()
  --     -- Disable for Parrot nvim chats
  --     return string.match(vim.fn.expand("%"), "nvim/parrot/chats")
  --   end,
  -- })
end

return M
