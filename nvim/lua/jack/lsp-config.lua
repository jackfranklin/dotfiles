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
  if config.custom_tsserver_path ~= nil then
    setup_opts.init_opts = {
      tsserver = config.custom_tsserver_path,
    }
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
    root_dir = function(name)
      -- When loading up my dotfiles, the Lua LS root should always be the nvim/ directory.
      if name:find("dotfiles", 1, true) then
        return os.getenv("HOME") .. "/dotfiles/nvim"
      end
      local result = util.root_pattern({ "stylua.toml", ".luarc.json", ".git" })(name)
      return result
    end,
    on_attach = config.on_attach,
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
