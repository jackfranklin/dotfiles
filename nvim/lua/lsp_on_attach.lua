local navic = require("nvim-navic")
local M = {}
local on_attach = function(client, bufnr)
  -- By binding these keys here, we ensure they are bound only once the language server is ready for them.
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
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
  buf_set_keymap("n", "ge", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
  buf_set_keymap("n", "gE", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)

  -- Disable formatexpr to allow Vim's built in gq to work.
  -- See: https://github.com/neovim/neovim/pull/19677
  -- In theory this idea works great but the TS language server doesn't wrap comments.
  vim.api.nvim_buf_set_option(bufnr, "formatexpr", "")

  -- neovim recently added support for LSP semantic highlighting, but when an
  -- autoformatter runs there is a very visual flash as the semantic highlights
  -- from the server are reapplied. The built in treesitter highlighting is
  -- plenty good enough for me and does not suffer from that problem. In the
  -- future when perhaps it is better cached and updated, I will try this
  -- again. It is still in an experimental state within neovim.
  -- Update 14 June 2023: setting this value to nil now causes errors and is not the recommended approach.
  -- :h lsp-semantic-highlight gives the following suggestion for disabling:
  -- go/rpp-features-eng-scoping
  -- You can disable semantic highlights by clearing the highlight groups: >lua

  --     -- Hide semantic highlights for functions
  vim.api.nvim_set_hl(0, "@lsp.type.function", {})

  --     -- Hide all semantic highlights
  for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
    vim.api.nvim_set_hl(0, group, {})
  end
  --  But for now I will instead try it out and see how it feels :)
  -- client.server_capabilities.semanticTokensProvider = nil
end

M.on_attach = on_attach

return M
