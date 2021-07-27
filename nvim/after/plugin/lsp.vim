if !exists('g:lspconfig')
  finish
endif

lua << EOF
--vim.lsp.set_log_level("debug")
EOF

lua << EOF
local nvim_lsp = require('lspconfig')

local on_attach = function(client, bufnr)
  -- By binding these keys here, we ensure they are bound only once the language server is ready for them.
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  local opts = { noremap=true, silent=true }

  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>Lspsaga hover_doc<CR>', opts)
  buf_set_keymap('n', '<C-p>', '<Cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
  buf_set_keymap('n', '<C-n>', '<Cmd>Lspsaga diagnostic_jump_next<CR>', opts)
  buf_set_keymap('n', '<leader>d', "<Cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>", opts)
  buf_set_keymap('n', '<leader>ca', "<Cmd>Lspsaga code_action<CR>", opts)
  buf_set_keymap('n', '<leader>cr', "<Cmd>Lspsaga rename<CR>", opts)

end

nvim_lsp.tsserver.setup {
  on_attach = on_attach,
  filetypes = { "typescript", "javascript" },
  cmd = { "typescript-language-server", "--stdio", "--tsserver-path", "./node_modules/.bin/tsserver" },
}

nvim_lsp.svelte.setup {
  on_attach = on_attach,
}

nvim_lsp.diagnosticls.setup {
  on_attach = on_attach,
  filetypes = {"javascript", "typescript"},
  init_options = {
    linters = {
      eslint = {
        command = "./node_modules/.bin/eslint",
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
      },
    },
    filetypes = {
      javascript = "eslint",
      typescript = "eslint"
    }
  }
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = false,
  }
)
EOF

