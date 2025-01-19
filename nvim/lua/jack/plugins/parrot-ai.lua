local M = {}

M.setup = function()
  require("parrot").setup({
    providers = {
      gemini = {
        api_key = os.getenv("GEMINI_API_KEY"),
      },
    },
  })
  vim.keymap.set("n", "<leader>ln", ":PrtChatNew<CR>", {
    desc = "Open a new chat with Parrot",
  })
  vim.keymap.set("n", "<leader>lt<CR>", ":PrtChatToggle<CR>", {
    desc = "Toggle chat with Parrot",
  })
end

return M
