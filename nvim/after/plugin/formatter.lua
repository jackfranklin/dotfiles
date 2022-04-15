local config_paths = require('config_paths')

local prettier_path = config_paths.prettier_path()

local formatter_filetypes = {
  javascript = {},
  svelte = {},
  typescript = {},
  css = {},
  rust = {
    function()
      return {
        exe = "rustfmt",
        args = {"--emit=stdout", "--edition=2021"},
        stdin = true,
      }
    end
  },
}

if prettier_path ~= nil then
  local prettier_formatter = function()
    return {
      exe = prettier_path,
      args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
      stdin = true
    }
  end

  table.insert(formatter_filetypes.javascript, prettier_formatter)
  table.insert(formatter_filetypes.svelte, prettier_formatter)
  table.insert(formatter_filetypes.css, prettier_formatter)
  table.insert(formatter_filetypes.typescript, prettier_formatter)

  -- TODO: better way to turn formatter on automatically - check if at least one formatter is defined for the current file type?
  vim.api.nvim_exec([[
  augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.js,*.svelte,*.ts,*.css FormatWrite
  augroup END
  ]], true)
end

require('formatter').setup({
  logging = false,
  filetype = formatter_filetypes,
})

-- TODO: this is annoying - want to really detect when vim is launched what formatters we should enable
vim.api.nvim_exec([[
augroup FormatAutogroup
autocmd!
autocmd BufWritePost *.js,*.svelte,*.ts,*.rs FormatWrite
augroup END
]], true)

