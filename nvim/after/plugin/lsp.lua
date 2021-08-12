local nvim_lsp = require('lspconfig')
local config_paths = require('config_paths')
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
  local eslint_config = {
    command = eslint_path,
    rootPatterns = {".git"},
    debounce = 100,
    args = {
      "--stdin",
      "--stdin-filename",
      "%filepath",
      "--format",
      "json"
    },
    sourceName = "eslint",
    parseJson = {
      errorsRoot = "[0].messages",
      line = "line",
      column = "column",
      endLine = "endLine",
      endColumn = "endColumn",
      message = "${message} [${ruleId}]",
      security = "severity"
    },
    securities = {
      [2] = "error",
      [1] = "warning"
    },
  }
  diagnostic_linters["eslint"] = eslint_config
  diagnostic_linter_filetypes["javascript"] = "eslint"
  diagnostic_linter_filetypes["typescript"] = "eslint"
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
    update_in_insert = false,
  }
)

