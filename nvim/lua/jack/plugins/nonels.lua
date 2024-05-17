local M = {}
local null_ls = require("null-ls")

M.setup = function()
  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
  null_ls.setup({
    sources = {
      -- LUA ONLY
      null_ls.builtins.formatting.stylua,

      -- FRONTEND THINGS
      null_ls.builtins.formatting.prettierd,
      require("none-ls.formatting.eslint_d"),
      require("none-ls.diagnostics.eslint_d"),
    },
    on_attach = function(client, bufnr)
      if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({
              bufnr = bufnr,
              async = false,

              filter = function(current_client)
                -- Only let null-ls deal with formatting - disable any
                -- other LSPs from formatting.
                return current_client.name == "null-ls"
              end,
            })
          end,
        })
      end
    end,
  })
end

return M
