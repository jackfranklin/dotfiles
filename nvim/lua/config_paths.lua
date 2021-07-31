local Path = require'plenary.path'

M = {}

local current_working_directory = vim.api.nvim_eval("getcwd()")
local node_modules_path = Path:new(current_working_directory):joinpath("node_modules")
local package_json_path = Path:new(current_working_directory):joinpath("package.json")
local tsconfig_path = Path:new(current_working_directory):joinpath("tsconfig.json")
local jsconfig_path = Path:new(current_working_directory):joinpath("jsconfig.json")

local create_printer = function(prefix)
  return function(message) 
    print(prefix .. ": " .. message)
  end
end

local eslint_configuration = function(config_options)
  config_options = config_options or {}
  local fallback_to_global = config_options.fallback_to_global or false
  local silence_debug = config_options.silence_debug or false
  local printer = create_printer("ESLint")

  local local_eslint_path = node_modules_path:joinpath(".bin"):joinpath("eslint")

  if local_eslint_path:exists() then
    return local_eslint_path:make_relative(current_working_directory)
  elseif package_json_path:exists() and not silence_debug then
    printer("Found package.json but no local ESLint; did you mean to npm install it?")
  elseif fallback_to_global then
    if not silence_debug then
      print("Falling back to global install.")
    end

    -- Global command; assume eslint is in the path
    return "eslint"
  end
end

local get_typescript_lsp_cmd = function(config_options)
  config_options = config_options or {}
  local fallback_to_global = config_options.fallback_to_global or false
  local silence_debug = config_options.silence_debug or false
  local printer = create_printer("TypeScript")
  local local_ts_path = node_modules_path:joinpath(".bin"):joinpath("tsserver")

  local ts_language_server_command = { "typescript-language-server", "--stdio" }

  if local_ts_path:exists() then
    table.insert(ts_language_server_command, "--tsserver-path", local_ts_path:make_relative(current_working_directory))
    return ts_language_server_command
  elseif tsconfig_path:exists() and not silence_debug then
    printer("Did not find local tsserver but did find tsconfig.json; did you mean to npm install it?")
    return ts_language_server_command
  elseif jsconfig_path:exists() and not silence_debug then
    printer("Did not find local tsserver but did find jsconfig.json; did you mean to npm install it?")
    return ts_language_server_command
  elseif fallback_to_global then
    if not silence_debug then
      printer("Falling back to global install.")
    end

    return ts_language_server_command
  end
  return nil
end

M.eslint_path = eslint_configuration
M.typescript_lsp_cmd = get_typescript_lsp_cmd

return M

