local cc = require("codecompanion")
local keys = require("jack.llm-keys")

local adapter = nil
if keys.has_gemini then
  adapter = "gemini"
elseif keys.has_github then
  adapter = "copilot"
else
  print(
    "CodeCompanion: No API key found for Gemini or GitHub Copilot. Please set the GEMINI_API_KEY or GITHUB_TOKEN environment variable."
  )
end

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
              default = "gemini-2.0-flash",
            },
          },
        })
      end,
    },
    strategies = {
      chat = {
        tools = {
          ["mcp"] = {
            -- Prevent mcphub from loading before needed
            callback = function()
              return require("mcphub.extensions.codecompanion")
            end,
            description = "Call tools and resources from the MCP Servers",
          },
        },
        adapter = adapter,
      },
      inline = {
        adapter = adapter,
      },
      cmd = {
        adapter = adapter,
      },
    },
  })
end

return M
