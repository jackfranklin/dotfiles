local M = {}

M.setup = function(config)
  vim.keymap.set("n", "<leader>t", function()
    require("fzf-lua").files()
  end)
  vim.keymap.set("n", "<leader>o", function()
    require("fzf-lua").oldfiles({ cwd_only = true })
  end)
  vim.keymap.set("n", "<leader>b", function()
    require("fzf-lua").buffers()
  end)
  vim.keymap.set("n", "<leader>fs", function()
    require("fzf-lua").lsp_document_symbols({
      symbol_style = 3,
      winopts = {
        preview = { hidden = "nohidden" },
      },
    })
  end)

  local ignore = { "^node_modules/", "^.git/" }
  local extraIgnores = config.extra_ignore_patterns or {}
  for _, value in ipairs(extraIgnores) do
    table.insert(ignore, value)
  end

  require("fzf-lua").setup({
    file_ignore_patterns = ignore,
    keymap = {
      fzf = {
        ["ctrl-q"] = "select-all+accept",
      },
    },
    winopts = {
      height = 0.4,
      preview = {
        hidden = "hidden",
      },
    },
    oldfiles = {
      cwd_only = true,
    },
  })
end

return M
