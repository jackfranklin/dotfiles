local nvim_lsp = require("lspconfig")
local util = require("lspconfig.util")
local config_paths = require("config_paths")
local on_attach = require("lsp_on_attach").on_attach
local lsp_config = require("jack.lsp-config")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local tsserver_command = config_paths.typescript_lsp_cmd()

lsp_config.typescript({
  on_attach = on_attach,
  cmd = tsserver_command,
})

lsp_config.eslint({})
lsp_config.lua({ on_attach = on_attach })
-- TODO: figure out if this is possible to have but not have completions appear
-- in nvim-cmp, because in TypeScript files they appear above most useful
-- completion suggestions
-- https://github.com/aca/emmet-ls/issues/42
-- lsp_config.emmet({ on_attach = on_attach })

lsp_config.css({ on_attach = on_attach })

nvim_lsp.elmls.setup({
  root_dir = function(name)
    return util.root_pattern("elm.json")(name)
  end,
  on_attach = on_attach,
})

nvim_lsp.svelte.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

nvim_lsp.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
      },
      completion = {
        addCallParenthesis = true,
        addCallArgumentSnippets = true,
      },
    },
  },
})
