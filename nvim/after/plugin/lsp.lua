local nvim_lsp = require('lspconfig')
local config_paths = require('config_paths')
local on_attach = require('lsp_on_attach').on_attach

local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` user.
    end,
  },
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = {
    { name = 'nvim_lsp', keyword_length = 2, max_item_count = 10 },
    { name = 'path', keyword_length = 2, max_item_count = 3 },
    { name = 'vsnip', keyword_length = 3, max_item_count = 2 },
    { name = 'buffer', max_item_count = 4, keyword_length = 8 }
  },
})


local tsserver_command = config_paths.typescript_lsp_cmd()

if tsserver_command ~= nil then
  nvim_lsp.tsserver.setup {
    on_attach = on_attach,
    filetypes = { "typescript", "javascript" },
    cmd = tsserver_command,
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
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

