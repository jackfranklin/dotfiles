local M = {}

M.setup = function()
  require("minuet").setup({
    virtualtext = {
      auto_trigger_ft = {}, -- do not enable by default. Use prev/next to trigger.
      keymap = {
        accept = "<A-a>",
        accept_line = "<A-l>",
        -- Cycle to prev completion item, or manually invoke completion
        prev = "<A-p>",
        -- Cycle to next completion item, or manually invoke completion
        next = "<A-n>",
        dismiss = "<A-e>",
      },
    },
    cmp = {
      -- This means that it is not auto-executed by cmp. But the ctrl-m
      -- keybinding (set in cmp.lua) triggers it.
      enable_auto_complete = false,
    },
    provider = "gemini",
  })
end

return M
