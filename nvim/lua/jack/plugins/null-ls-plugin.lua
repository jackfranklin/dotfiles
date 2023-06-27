local null_ls = require("null-ls")
-- local helpers = require("null-ls.helpers")

local format_with_null_ls = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      return client.name == "null-ls"
    end,
    buffer = bufnr,
    async = false,
  })
end
local M = {}

M.setup = function()
  null_ls.setup({
    sources = {
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.eslint_d.with({
        condition = function(utils)
          return utils.root_has_file({ ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.mjs" })
        end,
      }),
      null_ls.builtins.formatting.prettierd.with({
        condition = function(utils)
          return utils.root_has_file({ "prettier.config.mjs", "prettier.config.js" })
        end,
      }),
    },
    on_attach = function(client, bufnr)
      -- Without this, null-ls will set the formatexpr when it attaches which
      -- we do not want, because it breaks text wrapping at 80chars, as Vim
      -- delegates to the language server.
      -- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1131
      vim.api.nvim_buf_set_option(bufnr, "formatexpr", "")
    end,
  })
end

M.install_lua_auto_formatting = function()
  local augroup = vim.api.nvim_create_augroup("LspLuaFormatting", {})
  vim.api.nvim_clear_autocmds({ group = augroup })
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.lua" },
    group = augroup,
    callback = function(id, event, group, match, bufnr)
      format_with_null_ls(bufnr)
    end,
  })
end
M.install_frontend_auto_formatting = function()
  local augroup = vim.api.nvim_create_augroup("LspFrontendFormatting", {})
  vim.api.nvim_clear_autocmds({ group = augroup })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    pattern = { "*.js", "*.ts", "*.css", "*.html", "*.json", "*.markdown" },
    callback = function(id, event, group, match, bufnr)
      format_with_null_ls(bufnr)
    end,
  })
end

return M
