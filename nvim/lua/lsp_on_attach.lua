M = {}
local on_attach = function(client, bufnr)
  -- By binding these keys here, we ensure they are bound only once the language server is ready for them.
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  -- local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  local opts = { noremap=true, silent=true }

  -- buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  -- buf_set_keymap('n', 'K', '<Cmd>Lspsaga hover_doc<CR>', opts)
  -- buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
  -- buf_set_keymap('n', '<C-p>', '<Cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
  -- buf_set_keymap('n', '<C-n>', '<Cmd>Lspsaga diagnostic_jump_next<CR>', opts)
  -- buf_set_keymap('n', '<leader>cd', "<Cmd>lua require'lspsaga.diagnostic'.show_cursor_diagnostics()<CR>", opts)
  -- buf_set_keymap('n', '<leader>ca', "<Cmd>Lspsaga code_action<CR>", opts)
  -- buf_set_keymap('n', '<leader>cr', "<Cmd>Lspsaga rename<CR>", opts)
  -- buf_set_keymap('n', '<leader>cs', "<Cmd>Lspsaga signature_help<CR>", opts)

  -- require "lsp_signature".on_attach({
  --   bind = true,
  --   hint_prefix = '',
  -- })

  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gS', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>cr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>cc', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '<C-p>', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', '<C-n>', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)


end

M.on_attach = on_attach

return M
