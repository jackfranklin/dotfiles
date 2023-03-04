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
  if config.cmd ~= nil then
    nvim_lsp.tsserver.setup({
      on_attach = config.on_attach,
      filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
      cmd = config.cmd,
      capabilities = capabilities,
    })
  end
end

M.eslint = function(config)
  local eslint_setup = {
    root_dir = function(name)
      return util.root_pattern("package.json")(name)
    end,
  }

  if config.nodePath ~= nil then
    eslint_setup.setting = {
      nodePath = config.nodePath,
    }
  end
  nvim_lsp.eslint.setup(eslint_setup)
end

M.lua = function(config)
  nvim_lsp.lua_ls.setup({
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
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  })
end

return M
