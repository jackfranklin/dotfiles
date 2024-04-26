local navic = require("nvim-navic")
local M = {}
local on_attach = function(client, bufnr)
  -- By binding these keys here, we ensure they are bound only once the language server is ready for them.
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  local map = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc, silent = true, noremap = true })
  end

  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  local opts = { noremap = true, silent = true }
  -- These are now set in fzf-lua.lua.
  -- buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  -- buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  map("K", vim.lsp.buf.hover, "hover information")

  -- buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  map("<leader>sh", vim.lsp.buf.signature_help, "[s]ignature [h]help")
  map("gi", vim.lsp.buf.implementation, "[g]oto [i]mplementation")

  map("<leader>cr", vim.lsp.buf.rename, "[c]hange [r]ename")
  map("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ction")
  map("<leader>cc", vim.diagnostic.open_float, "[c]ode [c]riticism (diagnostics)")
  map("ge", vim.diagnostic.goto_next, "[g]o to next [e]rror (diagnostics)")
  map("gE", vim.diagnostic.goto_prev, "[g]o to previous [E]rror (diagnostics)")

  -- Disable formatexpr to allow Vim's built in gq to work.
  -- See: https://github.com/neovim/neovim/pull/19677
  -- In theory this idea works great but the TS language server doesn't wrap comments.
  vim.api.nvim_buf_set_option(bufnr, "formatexpr", "")

  -- Semantic highlighting
  -- :h lsp-semantic-highlight gives the following suggestion for disabling:
  -- You can disable semantic highlights by clearing the highlight groups: >lua

  --     -- Hide all semantic highlights
  -- for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
  --   vim.api.nvim_set_hl(0, group, {})
  -- end
  --  But for now I will instead try it out and see how it feels :)
  -- client.server_capabilities.semanticTokensProvider = nil
end

M.on_attach = on_attach

return M
