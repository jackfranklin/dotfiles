local Path = require("plenary.path")

local M = {}

M.make_path_relative_to_cwd = function(file_name)
  local cwd = vim.fn.getcwd()
  return tostring(Path:new(file_name):make_relative(cwd))
end

M.path_exists = function(path)
  return Path:new(path):exists()
end

M.at_least_nvim_0_11 = function()
  local version = vim.version()
  return version.major == 0 and version.minor >= 11 or version.major > 0
end

return M
