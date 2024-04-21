local M = {}

M.setup = function(config)
  vim.keymap.set("n", "<leader>t", function()
    require("fzf-lua").files({
      git_icons = false,
      file_icons = false,
      no_header_i = true,
    })
  end, { desc = "Find files" })
  vim.keymap.set("n", "<leader>fb", function()
    require("fzf-lua").buffers()
  end, { desc = "Find [b]uffers" })

  vim.keymap.set("n", "<leader>fs", function()
    require("fzf-lua").lsp_document_symbols({
      symbol_style = 3,
      winopts = {
        preview = { hidden = "nohidden" },
      },
      no_header_i = true,
    })
  end, { desc = "[f]ind LSP [s]ymbols" })

  vim.keymap.set("n", "<leader>fd", function()
    local cwd_for_buf = vim.fn.expand("%:h")
    require("fzf-lua").files({
      git_icons = false,
      file_icons = false,
      cwd = cwd_for_buf,
      no_header_i = true,
    })
  end, { desc = "Find [f]iles in [d]irectory" })

  vim.keymap.set("n", "gd", function()
    require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
  end, { desc = "Find LSP [d]efinitions" })

  vim.keymap.set("n", "gr", function()
    require("fzf-lua").lsp_references({ jump_to_single_result = true })
  end, { desc = "Find LSP [r]eferences" })

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
      height = 0.3,
      width = 1,
      row = 1,
      preview = {
        hidden = "hidden",
      },
    },
    oldfiles = {
      cwd_only = true,
    },
  })

  require("fzf-lua").register_ui_select()
end

return M
