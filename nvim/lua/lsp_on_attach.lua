local navic = require("nvim-navic")
local M = {}
local on_attach = function(client, bufnr)
  local map = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc, silent = true, noremap = true })
  end

  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  -- These are now set in fzf-lua.lua.
  -- buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  -- buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  map("K", vim.lsp.buf.hover, "hover information")
  map("sh", vim.lsp.buf.signature_help, "[s]ignature [h]help")
  map("gi", vim.lsp.buf.implementation, "[g]oto [i]mplementation")

  map("<leader>cr", vim.lsp.buf.rename, "[c]hange [r]ename")
  map("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ction")
  map("<leader>cc", vim.diagnostic.open_float, "[c]ode [c]riticism (diagnostics)")
  map("ge", vim.diagnostic.goto_next, "[g]o to next [e]rror (diagnostics)")
  map("gE", vim.diagnostic.goto_prev, "[g]o to previous [E]rror (diagnostics)")

  map("gx", function()
    require("treesitter-context").go_to_context(vim.v.count1)
  end, "[g]o to the conte[x]t")
end

M.on_attach = on_attach

return M
