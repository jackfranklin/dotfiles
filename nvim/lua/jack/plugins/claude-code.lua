local M = {}

M.setup = function()
  require("claude-code").setup({
    keymaps = {
      toggle = {
        normal = false,
        terminal = false,
        variants = {
          continue = false,
          verbose = false,
        },
      },
    },
    window = {
      position = "vsplit",
      split_ratio = 0.5,
    },
  })

  M.bind_keymaps()
end

M.bind_keymaps = function()
  vim.keymap.set("n", "<leader>xcc", ":ClaudeCode<CR>", {
    desc = "[claude [c]ode: open Claude Code interface",
  })
  vim.keymap.set("n", "<leader>xcr", ":ClaudeCodeResume<CR>", {
    desc = "[claude [r]esume: resume a previous Claude Code session",
  })
end

return M
