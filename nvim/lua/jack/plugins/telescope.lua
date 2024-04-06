local M = {}
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")

M.setup = function(config)
  local file_ignore_patterns = { "^node_modules/", "^.git/" }
  local extraIgnores = config.extra_ignore_patterns or {}
  for _, value in ipairs(extraIgnores) do
    table.insert(file_ignore_patterns, value)
  end

  vim.keymap.set("n", "<leader>tf", builtin.find_files, {})
  vim.keymap.set("n", "<leader>td", function()
    builtin.find_files({ cwd = vim.fn.expand("%:p:h") })
  end)
  vim.keymap.set("n", "<leader>tb", builtin.buffers, {})
  vim.keymap.set("n", "<leader>ts", builtin.lsp_document_symbols, {})
  vim.keymap.set("n", "<leader>tc", builtin.command_history, {})

  -- LSP replacements for basic goto refs & goto defs
  vim.keymap.set("n", "gr", builtin.lsp_references, {})
  vim.keymap.set("n", "gd", builtin.lsp_definitions, {})

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
    },
  })
  require("telescope").load_extension("fzf")
end

return M
