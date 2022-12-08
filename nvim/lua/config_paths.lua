local Path = require("plenary.path")

M = {}

local current_working_directory = vim.api.nvim_eval("getcwd()")
local node_modules_path = Path:new(current_working_directory):joinpath("node_modules")
local package_json_path = Path:new(current_working_directory):joinpath("package.json")
local eslintrc_path = Path:new(current_working_directory):joinpath(".eslintrc.js")
local tsconfig_path = Path:new(current_working_directory):joinpath("tsconfig.json")
local jsconfig_path = Path:new(current_working_directory):joinpath("jsconfig.json")

local create_printer = function(prefix, should_debug)
	local debug = should_debug or false
	return function(message)
		if debug then
			print(prefix .. ": " .. message)
		end
	end
end

local error_and_return_nil = function(prefix, message)
	print(prefix .. ": " .. message)
	return nil
end

local global_executable_exists = function(executable_name)
	return vim.api.nvim_eval("executable('" .. executable_name .. "')") == 1
end

local eslint_configuration = function(config_options)
	config_options = config_options or {}
	local fallback_to_global = config_options.fallback_to_global or false
	local debug = config_options.debug or false
	local prefer_eslint_d = config_options.prefer_eslint_d or false
	local printer = create_printer("ESLint", debug)

	local local_eslint_path = node_modules_path:joinpath(".bin"):joinpath("eslint")
	local has_eslint_d_executable = global_executable_exists("eslint_d")
	local has_global_eslint = global_executable_exists("eslint")

	if prefer_eslint_d and has_eslint_d_executable then
		return vim.api.nvim_eval("exepath('eslint_d')")
	elseif local_eslint_path:exists() then
		return local_eslint_path:make_relative(current_working_directory)
	end

	if eslintrc_path:exists() then
		printer("Found .eslintrc.js but no local ESLint; did you mean to npm install it?")
	end

	if fallback_to_global then
		if has_global_eslint then
			printer("Falling back to global install.")
			return vim.api.nvim_eval("exepath('eslint')")
		end

		return error_and_return_nil("ESLint", "fallback_to_global set but no eslint global found")
	end
end

local get_prettier_executable = function(config_options)
	config_options = config_options or {}
	local silence_debug = config_options.silence_debug or false
	local printer = create_printer("Prettier")

	local local_prettier_path = node_modules_path:joinpath(".bin"):joinpath("prettier")

	if local_prettier_path:exists() then
		return local_prettier_path:make_relative(current_working_directory)
	elseif package_json_path:exists() and not silence_debug then
		printer("Found package.json but no local Prettier; did you mean to npm install it?")
	end
	return nil
end

local get_typescript_lsp_cmd = function(config_options)
	config_options = config_options or {}
	local fallback_to_global = config_options.fallback_to_global or false
	local silence_debug = config_options.silence_debug or false
	local printer = create_printer("TypeScript")
	local local_ts_path = node_modules_path:joinpath(".bin"):joinpath("tsserver")

	local ts_language_server_command = { "typescript-language-server", "--stdio" }

	if local_ts_path:exists() then
		table.insert(ts_language_server_command, "--tsserver-path")
		table.insert(ts_language_server_command, tostring(local_ts_path:make_relative(current_working_directory)))
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
M.prettier_path = get_prettier_executable

return M
