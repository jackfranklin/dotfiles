M = {}
local on_attach = function(client, bufnr)
  -- By binding these keys here, we ensure they are bound only once the language server is ready for them.
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  -- local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  local opts = { noremap=true, silent=true }

  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>Lspsaga hover_doc<CR>', opts)
  buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<C-p>', '<Cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
  buf_set_keymap('n', '<C-n>', '<Cmd>Lspsaga diagnostic_jump_next<CR>', opts)
  buf_set_keymap('n', '<leader>cd', "<Cmd>lua require'lspsaga.diagnostic'.show_cursor_diagnostics()<CR>", opts)
  buf_set_keymap('n', '<leader>ca', "<Cmd>Lspsaga code_action<CR>", opts)
  buf_set_keymap('n', '<leader>cr', "<Cmd>Lspsaga rename<CR>", opts)
  buf_set_keymap('n', '<leader>cs', "<Cmd>Lspsaga signature_help<CR>", opts)

end

M.on_attach = on_attach

return M
