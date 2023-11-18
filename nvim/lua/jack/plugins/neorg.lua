local M = {}
M.setup = function()
  require("neorg").setup({
    load = {
      ["core.defaults"] = {}, -- Loads default behaviour
      ["core.concealer"] = {}, -- Adds pretty icons to your documents
      ["core.dirman"] = { -- Manages Neorg workspaces
        config = {
          workspaces = {
            notes = "~/git/notes",
          },
          default_workspace = "notes",
        },
      },
    },
  })
end
return M
