local conform = require("conform")

local M = {}

M.setup = function(config)
  conform.setup({
    log_level = vim.log.levels.DEBUG,
    formatters_by_ft = {
      lua = {
        "stylua",
      },
      javascript = {
        "eslint_d",
        "prettierd",
      },
      typescript = {
        "eslint_d",
        "prettierd",
      },
      markdown = {
        "prettierd",
      },
      css = {
        "prettierd",
      },
    },
    format_on_save = {
      lsp_fallback = false,
      timeout_ms = 2000,
    },
  })
end

return M
