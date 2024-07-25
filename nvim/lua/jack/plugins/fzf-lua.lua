local M = {}

M.setup = function(config)
  vim.keymap.set("n", "<leader>t", function()
    require("fzf-lua").files({
      git_icons = false,
      file_icons = false,
      no_header_i = true,
      winopts = {
        backdrop = false,
        preview = { hidden = "hidden" },
      },
    })
  end, { desc = "Find files" })
  vim.keymap.set("n", "<leader>fb", function()
    require("fzf-lua").buffers({
      git_icons = false,
      file_icons = false,
      no_header_i = true,
      winopts = {
        backdrop = false,
        preview = { hidden = "hidden" },
      },
    })
  end, { desc = "Find [b]uffers" })

  vim.keymap.set("n", "<leader>fs", function()
    require("fzf-lua").lsp_document_symbols({
      symbol_style = 3,
      no_header_i = true,
      winopts = {
        backdrop = false,
      },
    })
  end, { desc = "[f]ind LSP [s]ymbols" })

  vim.keymap.set("n", "<leader>fd", function()
    local cwd_for_buf = vim.fn.expand("%:h")
    require("fzf-lua").files({
      git_icons = false,
      file_icons = false,
      cwd = cwd_for_buf,
      no_header_i = true,
      winopts = {
        backdrop = false,
        preview = { hidden = "hidden" },
      },
    })
  end, { desc = "Find [f]iles in [d]irectory" })

  vim.keymap.set("n", "gd", function()
    require("fzf-lua").lsp_definitions({ jump_to_single_result = true, winopts = { backdrop = false } })
  end, { desc = "Find LSP [d]efinitions" })

  -- Overwrites gt (go to next tab) but I have PageDown mapped to that.
  vim.keymap.set("n", "gt", function()
    require("fzf-lua").lsp_typedefs({ jump_to_single_result = true, winopts = { backdrop = false } })
  end, { desc = "Find LSP [t]ypedefs" })

  vim.keymap.set("n", "gr", function()
    require("fzf-lua").lsp_references({ jump_to_single_result = true, winopts = { backdrop = false } })
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
    fzf_opts = {
      ["--color"] = config.fzf_theme or "dark",
    },
    winopts = {
      height = 0.3,
      width = 1,
      row = 1,
    },
    oldfiles = {
      cwd_only = true,
    },
  })

  require("fzf-lua").register_ui_select()
end

return M
