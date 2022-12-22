local M = {}
local on_attach = function(client, bufnr)
  -- By binding these keys here, we ensure they are bound only once the language server is ready for them.
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  local opts = { noremap = true, silent = true }

  buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  buf_set_keymap("n", "<leader>cr", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  buf_set_keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  buf_set_keymap("n", "<leader>cc", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
  buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)

  -- Disable formatexpr to allow Vim's built in gq to work.
  -- See: https://github.com/neovim/neovim/pull/19677
  -- In theory this idea works great but the TS language server doesn't wrap comments.
  vim.api.nvim_buf_set_option(bufnr, "formatexpr", "")
end

M.on_attach = on_attach

return M
