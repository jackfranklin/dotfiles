vim.api.nvim_set_keymap("n", "<leader>t", ":lua require('fzf-lua').files()<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>o", "<cmd>lua require('fzf-lua').oldfiles()<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>b", "<Cmd>lua require('fzf-lua').buffers()<CR>", {})
vim.api.nvim_set_keymap("n", "<leader>s", "<Cmd>lua require('fzf-lua').lsp_document_symbols<CR>", {})

require("fzf-lua").setup({
  file_ignore_patterns = { "^node_modules/", "^dwarf_extension/", "^third_party/", "^.git/", "%.json.gz" },
  winopts = {
    height = 0.2,
    preview = {
      hidden = "hidden",
    },
  },
  oldfiles = {
    cwd_only = true,
  },
})
