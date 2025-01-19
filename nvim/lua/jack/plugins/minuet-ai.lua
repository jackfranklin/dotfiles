local M = {}

M.setup = function()
  print("I am being setup!")
  require("minuet").setup({
    -- virtualtext = {
    --   auto_trigger_ft = {},
    --   keymap = {
    --     accept = "<A-A>",
    --     accept_line = "<A-a>",
    --     -- Cycle to prev completion item, or manually invoke completion
    --     prev = "<A-[>",
    --     -- Cycle to next completion item, or manually invoke completion
    --     next = "<A-]>",
    --     dismiss = "<A-e>",
    --   },
    -- },
    cmp = {
      enable_auto_complete = false,
    },
    provider = "gemini",
  })
end

return M
