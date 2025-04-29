local cc = require("codecompanion")

local M = {}
M.setup = function()
  cc.setup({
    opts = {
      -- log_level = "DEBUG",
    },
    adapters = {
      gemini = function()
        return require("codecompanion.adapters").extend("gemini", {
          schema = {
            model = {
              default = "gemini-2.5-pro-exp-03-25",
            },
          },
        })
      end,
    },
    strategies = {
      chat = {
        adapter = "gemini",
        tools = {
          ["mcp"] = {
            -- Prevent mcphub from loading before needed
            callback = function()
              return require("mcphub.extensions.codecompanion")
            end,
            description = "Call tools and resources from the MCP Servers",
          },
        },
      },
      inline = {
        adapter = "gemini",
      },
      cmd = {
        adapter = "gemini",
      },
    },
  })
end

return M
