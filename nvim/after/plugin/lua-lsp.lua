local on_attach = require('lsp_on_attach').on_attach
local Path = require'plenary.path'

--[[
This is taken from nlua.vim (https://github.com/tjdevries/nlua.nvim)
because I couldn't quite get nlua.nvim working with the lua language server
installed into the right place. So I manually install the lua server and then
take this code from nlua.nvim and change the paths to the lua language server.
I hope in the future to move back to using the plugin out right!
--]]
local system_name
if vim.fn.has("mac") == 1 then
  system_name = "macOS"
elseif vim.fn.has("unix") == 1 then
  system_name = "Linux"
elseif vim.fn.has('win32') == 1 then
  system_name = "Windows"
else
  print("Unsupported system for sumneko")
end

local sumneko_root_path = '/home/jack/git/lua-language-server'
if not Path:new(sumneko_root_path):exists() then
  print("Lua: could not find sumneko lua-language-server path")
  return
end

local sumneko_binary = sumneko_root_path.."/bin/"..system_name.."/lua-language-server"

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

local function get_lua_runtime()
  local result = {};
  for _, path in pairs(vim.api.nvim_list_runtime_paths()) do
      local lua_path = path .. "/lua/";
      if vim.fn.isdirectory(lua_path) then
          result[lua_path] = true
      end
  end

  -- This loads the `lua` files from nvim into the runtime.
  result[vim.fn.expand("$VIMRUNTIME/lua")] = true

  -- TODO: Figure out how to get these to work...
  --  Maybe we need to ship these instead of putting them in `src`?...
  result[vim.fn.expand("~/build/neovim/src/nvim/lua")] = true

  return result;
end

require'lspconfig'.sumneko_lua.setup {
  cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = get_lua_runtime(),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

