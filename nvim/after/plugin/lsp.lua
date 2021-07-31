local nvim_lsp = require('lspconfig')
local config_paths = require('local_tools')
local on_attach = require('lsp_on_attach').on_attach


local tsserver_command = config_paths.typescript_lsp_cmd()

if tsserver_command ~= nil then
  nvim_lsp.tsserver.setup {
    on_attach = on_attach,
    filetypes = { "typescript", "javascript" },
    cmd = tsserver_command
  }
end

nvim_lsp.svelte.setup {
  on_attach = on_attach,
}

local diagnostic_linters = {}
local diagnostic_linter_filetypes = {}

local eslint_path = config_paths.eslint_path()
if eslint_path ~= nil then
  diagnostic_linters["eslint"] = eslint_path
  diagnostic_linter_filetypes["javascript"] = eslint_path
  diagnostic_linter_filetypes["typescript"] = eslint_path
end

nvim_lsp.diagnosticls.setup {
  on_attach = on_attach,
  filetypes = {"javascript", "typescript"},
  init_options = {
    linters = diagnostic_linters,
    filetypes = diagnostic_linter_filetypes
  }
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = false,
  }
)

