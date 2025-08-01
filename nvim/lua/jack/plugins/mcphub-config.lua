local M = {}

M.setup = function()
  require("mcphub").setup({
    json_decode = require("json5").parse,
    -- extensions = {
    --   codecompanion = {
    --     -- Show the mcp tool result in the chat buffer
    --     show_result_in_chat = true,
    --     -- Make chat #variables from MCP server resources
    --     make_vars = true,
    --     -- Create slash commands for prompts
    --     make_slash_commands = true,
    --   },
    -- },
  })
end

return M
