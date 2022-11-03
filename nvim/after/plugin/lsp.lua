local nvim_lsp = require('lspconfig')
local util = require('lspconfig.util')
local config_paths = require('config_paths')
local on_attach = require('lsp_on_attach').on_attach

local cmp = require'cmp'
cmp.setup({
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  snippet = {
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` user.
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<C-y>'] = cmp.mapping(
      cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      },
      { "i", "c" }
    ),
    ['<C-n>'] = {
      i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    },
    ['<C-p>'] = {
      i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    },
  },
  sources = {
    { name = 'nvim_lsp', max_item_count = 10 },
    { name = 'path', keyword_length = 3, max_item_count = 10 },
    { name = 'luasnip', max_item_count = 5 },
    { name = 'buffer', max_item_count = 10, keyword_length = 4 },
    { name = 'nvim_lua', max_item_count = 4, keyword_length = 2 }
  },
})

capabilities = require('cmp_nvim_lsp').default_capabilities()

local tsserver_command = config_paths.typescript_lsp_cmd()

if tsserver_command ~= nil then
  nvim_lsp.tsserver.setup {
    on_attach = on_attach,
    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
    cmd = tsserver_command,
    capabilities = capabilities,
  }
end

nvim_lsp.svelte.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

nvim_lsp.rust_analyzer.setup {
  on_attach = on_attach,
    capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy"
      },
      completion = {
        addCallParenthesis = true,
        addCallArgumentSnippets = true,
      },
    }
  }
}

-- local diagnostic_linters = {}
-- local diagnostic_linter_filetypes = {}

-- local eslint_path = config_paths.eslint_path()
-- if eslint_path ~= nil then
--   local eslint_config = {
--     command = eslint_path,
--     rootPatterns = {".git"},
--     debounce = 100,
--     args = {
--       "--stdin",
--       "--stdin-filename",
--       "%filepath",
--       "--format",
--       "json"
--     },
--     sourceName = "eslint",
--     parseJson = {
--       errorsRoot = "[0].messages",
--       line = "line",
--       column = "column",
--       endLine = "endLine",
--       endColumn = "endColumn",
--       message = "${message} [${ruleId}]",
--       security = "severity"
--     },
--     securities = {
--       ["2"] = "error",
--       ["1"] = "warning"
--     },
--   }
--   diagnostic_linters["eslint"] = eslint_config
--   diagnostic_linter_filetypes["javascript"] = "eslint"
--   diagnostic_linter_filetypes["typescript"] = "eslint"
-- end

-- nvim_lsp.diagnosticls.setup {
--   on_attach = on_attach,
--   filetypes = {"javascript", "typescript"},
--   init_options = {
--     linters = diagnostic_linters,
--     filetypes = diagnostic_linter_filetypes
--   }
-- }

nvim_lsp.eslint.setup({
  root_dir = function(name)
    return util.root_pattern('tsconfig.json')(name)
  end,
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = false,
    update_in_insert = false,
  }
)

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

nvim_lsp.sumneko_lua.setup {
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
   },
 }
