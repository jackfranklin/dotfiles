local M = {}
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")

M.setup = function(config)
  local file_ignore_patterns = { "^node_modules/", "^.git/" }
  local extraIgnores = config.extra_ignore_patterns or {}
  for _, value in ipairs(extraIgnores) do
    table.insert(file_ignore_patterns, value)
  end

  -- <leader>t for finding files (a hangover from my Cmd+T days)
  -- But everything else (that isn't LSP gotos) is prefixed <leader>f (for "find")
  vim.keymap.set("n", "<leader>t", builtin.find_files, { desc = "Find [f]iles in project" })

  vim.keymap.set("n", "<leader>fd", function()
    builtin.find_files({ cwd = vim.fn.expand("%:p:h") })
  end, { desc = "Find files in same [d]irectory" })
  vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find [b]uffers" })
  vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find LSP [s]ymbols" })
  vim.keymap.set("n", "<leader>fc", builtin.command_history, { desc = "Browse Vim [c]ommand history " })

  -- LSP replacements for basic goto refs & goto defs
  vim.keymap.set("n", "gr", builtin.lsp_references, { desc = "Find LSP [r]eferences " })
  vim.keymap.set("n", "gd", builtin.lsp_definitions, { desc = "Find LSP [d]efinitions " })

  require("telescope").setup({
    defaults = {
      preview = false,
      layout_config = {
        height = 0.7,
      },
      file_ignore_patterns = file_ignore_patterns,
      mappings = {
        i = {
          ["<esc>"] = actions.close,
        },
      },
    },
    pickers = {
      buffers = {
        preview = true,
      },
      lsp_references = {
        preview = true,
      },
      lsp_definitions = {
        preview = true,
      },
      lsp_document_symbols = {
        preview = true,
      },
    },
  })
  require("telescope").load_extension("fzf")
end

return M
