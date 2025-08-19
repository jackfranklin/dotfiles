local format_on_save = require("jack.format-on-save")
local M = {}

M.setup = function(config, auto_format_on_save)
  auto_format_on_save = auto_format_on_save or false

  local default_settings = {
    -- https://github.com/esmuellert/nvim-eslint for docs.
    settings = {
      -- run = "onSave",
      format = true,
    },
  }
  local final_config = vim.tbl_deep_extend("force", default_settings, config or {})
  require("nvim-eslint").setup(final_config)

  if auto_format_on_save then
    format_on_save.register_lsp_for_autoformat("eslint")
  end

  vim.api.nvim_create_user_command("ESLintFormat", function()
    vim.lsp.buf.format({
      filter = function(client)
        return client.name == "eslint"
      end,
      timeout_ms = 2000,
    })
  end, {})
end

return M
