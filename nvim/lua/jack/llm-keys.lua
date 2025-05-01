local M = {}

M.env = {}
M.env.gemini = "GEMINI_API_KEY"
M.env.github = "GITHUB_TOKEN"

local function env_var_exists(var_name)
  return os.getenv(var_name) ~= nil
end

local has_gemini_key = env_var_exists(M.env.gemini)
local has_github_copilot_token = env_var_exists(M.env.github)

M.has_github = has_github_copilot_token
M.has_gemini = has_gemini_key

return M
