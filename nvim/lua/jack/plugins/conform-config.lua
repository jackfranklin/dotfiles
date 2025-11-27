local conform = require("conform")
local M = {}

M.setup = function()
  conform.setup({
    -- log_level = vim.log.levels.DEBUG,
    formatters = {
      ["clang-format"] = {
        condition = function(_, context)
          return string.find(context.dirname, "devtools-frontend", 1, true) ~= nil
        end,
        command = "/Users/jacktfranklin/src/depot_tools/clang-format",
      },
      prettierd = {
        require_cwd = true,
      },
    },
    formatters_by_ft = {
      typescript = { "clang-format", "prettierd" },
      javascript = { "clang-format", "prettierd" },
      -- To install: pipx install black
      python = { "black" },
      css = { "prettierd" },
      markdown = { "prettierd" },
      lua = { "stylua" },
    },
  })
end
return M
