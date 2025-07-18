local M = {}

local lsp_clients_that_format = {}

M.register_lsp_for_autoformat = function(name)
  lsp_clients_that_format[name] = true
end

M.create_autocmd = function()
  local augroup = vim.api.nvim_create_augroup("JackAutoFormat", {})
  vim.api.nvim_clear_autocmds({ group = augroup })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    pattern = "*",
    callback = function(args)
      local clients = vim.lsp.get_clients({ bufnr = args.buf })
      local found_formatting_client = false
      for _, client in pairs(clients) do
        if lsp_clients_that_format[client.name] == true then
          found_formatting_client = true
          break
        end
      end

      -- TODO: I think when I migrate the LSP stuff to Neovim 0.11 then this
      -- will need updating
      if vim.fn.exists(":EslintFixAll") ~= 0 then
        vim.cmd("EslintFixAll")
      end

      if found_formatting_client then
        vim.lsp.buf.format({
          bufnr = args.buf,
          timeout_ms = 5000,
          async = false,

          filter = function(current_client)
            return lsp_clients_that_format[current_client.name] == true
          end,
        })
      end

      local success, conform = pcall(require, "conform")
      if success then
        conform.format({ bufnr = args.buf })
      end
    end,
  })
end

return M
