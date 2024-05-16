local nvim_lsp = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local util = require("lspconfig.util")

vim.diagnostic.config({
  virtual_text = false,
  signs = false,
  update_in_insert = false,
  float = {
    border = "rounded",
  },
})
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})

local M = {}
M.typescript = function(config)
  local setup_opts = {
    on_attach = config.on_attach,
    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
    capabilities = capabilities,
  }

  if config.cmd ~= nil then
    setup_opts.cmd = config.cmd
  end

  nvim_lsp.tsserver.setup(setup_opts)
end

M.css = function(config)
  -- We do have snippet support
  local css_capabilities = vim.lsp.protocol.make_client_capabilities()
  css_capabilities.textDocument.completion.completionItem.snippetSupport = true
  nvim_lsp.cssls.setup({
    capabilities = css_capabilities,
    on_attach = config.on_attach,
  })
end

M.eslint = function(config)
  local eslint_setup = {
    root_dir = function(name)
      return util.root_pattern("package.json")(name)
    end,
  }

  local final_setup = vim.tbl_deep_extend("force", eslint_setup, config or {})
  nvim_lsp.eslint.setup(final_setup)
end

M.lua = function(config)
  nvim_lsp.lua_ls.setup({
    on_attach = config.on_attach,
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
        },

        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim" },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  })
end

M.emmet = function(config)
  local emmet_capabilities = require("cmp_nvim_lsp").default_capabilities()
  emmet_capabilities.textDocument.completion.completionItem.snippetSupport = true

  nvim_lsp.emmet_ls.setup({
    on_attach = config.on_attach,
    capabilities = emmet_capabilities,
    filetypes = { "html", "typescriptreact", "javascriptreact", "css", "typescript" },
  })
end
return M
