local M = {}
M.setup = function()
  require("copilot").setup({
    panel = {
      auto_refresh = true,
    },
    suggestion = {
      auto_trigger = true,
      keymap = {
        accept = "<A-y>",
        accept_line = "<A-l>",
        -- Cycle to prev completion item, or manually invoke completion
        prev = "<A-p>",
        -- Cycle to next completion item, or manually invoke completion
        next = "<A-n>",
        dismiss = "<A-e>",
      },
    },
  })
end

return M
