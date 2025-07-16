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
              default = "gemini-2.5-flash",
            },
          },
        })
      end,
    },
    strategies = {
      chat = {
        tools = {
          opts = {
            auto_submit_success = true,
          },
        },
        adapter = adapter,
      },
      inline = {
        adapter = adapter,
        keymaps = {
          accept_change = {
            modes = { n = "gA" },
            description = "Accept the suggested change",
          },
          reject_change = {
            modes = { n = "gR" },
            description = "Reject the suggested change",
          },
        },
      },
      cmd = {
        adapter = adapter,
      },
    },
    extensions = {
      mcphub = {
        callback = "mcphub.extensions.codecompanion",
        opts = {
          show_result_in_chat = false, -- Show the mcp tool result in the chat buffer
          make_vars = true, -- make chat #variables from MCP server resources
          make_slash_commands = true, -- make /slash_commands from MCP server prompts
        },
      },
    },
  })

  M.bind_keymaps()
end

M.bind_keymaps = function()
  vim.keymap.set("n", "<leader>xct", ":CodeCompanionChat toggle<CR>", {
    desc = "[x] [c]hat [t]oggle: toggle the current CodeCompanionChat (or create a new one)",
  })
end

return M
