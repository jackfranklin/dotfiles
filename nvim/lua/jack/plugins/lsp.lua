require("neodev").setup()
local lsp_config = require("jack.lsp-config")
local format_on_save = require("jack.format-on-save")

lsp_config.typescript({})
lsp_config.eslint()
-- TODO: does this work with the eslint server?
-- Or do we need to use the special ESLintFixAll command?
format_on_save.register_lsp_for_autoformat("eslint")

lsp_config.lua()

-- TODO: figure out if this is possible to have but not have completions appear
-- in nvim-cmp, because in TypeScript files they appear above most useful
-- completion suggestions
-- https://github.com/aca/emmet-ls/issues/42
-- lsp_config.emmet({ on_attach = on_attach })
lsp_config.css()

-- TODO: migrate to new config
-- nvim_lsp.elmls.setup({
--   root_dir = function(name)
--     return util.root_pattern("elm.json")(name)
--   end,
--   on_attach = on_attach,
-- })

vim.lsp.enable("pylsp")

-- TODO: migrate to new config
-- nvim_lsp.svelte.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
-- })

-- TODO: migrate to new config
-- nvim_lsp.rust_analyzer.setup({
--   on_attach = function(client, bufnr)
--     on_attach(client, bufnr)
--   end,
--   capabilities = capabilities,
--   settings = {
--     ["rust-analyzer"] = {
--       checkOnSave = {
--         command = "clippy",
--       },
--       completion = {
--         addCallParenthesis = true,
--         addCallArgumentSnippets = true,
--       },
--     },
--   },
-- })
-- format_on_save.register_lsp_for_autoformat("rust_analyzer")
