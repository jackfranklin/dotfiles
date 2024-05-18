local Path = require("plenary.path")

local M = {}

M.make_path_relative_to_cwd = function(file_name)
  local cwd = vim.fn.getcwd()
  return tostring(Path:new(file_name):make_relative(cwd))
end

M.path_exists = function(path)
  return Path:new(path):exists()
end

return M
