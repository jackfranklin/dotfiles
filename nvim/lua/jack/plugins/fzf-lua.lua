local M = {}

M.setup = function(config)
  vim.keymap.set("n", "<leader>t", function()
    require("fzf-lua").files({
      git_icons = false,
      file_icons = false,
      no_header_i = true,
    })
  end)
  vim.keymap.set("n", "<leader>o", function()
    require("fzf-lua").oldfiles({ cwd_only = true })
  end)
  vim.keymap.set("n", "<leader>fw", function()
    require("fzf-lua").lsp_live_workspace_symbols({
      symbol_style = 3,
      winopts = {
        preview = { hidden = "nohidden" },
      },
      no_header_i = true,
    })
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
      no_header_i = true,
    })
  end)

  vim.keymap.set("n", "<leader>fd", function()
    local cwd_for_buf = vim.fn.expand("%:h")
    require("fzf-lua").files({
      git_icons = false,
      file_icons = false,
      cwd = cwd_for_buf,
      no_header_i = true,
    })
  end)

  vim.keymap.set("n", "gd", function()
    require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
  end)

  vim.keymap.set("n", "gr", function()
    require("fzf-lua").lsp_references({ jump_to_single_result = true })
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
