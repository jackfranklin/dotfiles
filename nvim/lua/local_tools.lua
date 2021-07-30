local Path = require'plenary.path'
local path = Path.path

local current_working_directory = vim.api.nvim_eval("getcwd()")


local node_modules_path = Path:new(current_working_directory):joinpath("node_modules")

local eslint_configuration = function()
  local local_eslint_path = node_modules_path:joinpath(".bin"):joinpath("eslint")

  print(local_eslint_path:exists())
end

eslint_configuration()
