local config_paths = require('config_paths')

local prettier_path = config_paths.prettier_path()

local formatter_filetypes = {
  javascript = {},
  javascriptreact = {},
  typescriptreact = {},
  svelte = {},
  typescript = {},
  css = {},
  lua = {
    require('formatter.filetypes.lua').stylua,
  },
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
  table.insert(formatter_filetypes.javascriptreact, prettier_formatter)
  table.insert(formatter_filetypes.typescriptreact, prettier_formatter)

end

require('formatter').setup({
  logging = false,
  filetype = formatter_filetypes,
})

-- TODO: better way to turn formatter on automatically - check if at least one formatter is defined for the current file type?
vim.api.nvim_exec([[
augroup FormatAutogroup
autocmd!
autocmd BufWritePost *.js,*.svelte,*.ts,*.rs,*.css,*.jsx,*.tsx,*.lua FormatWrite
augroup END
]], true)

-- Run Elm-format via the LSP formatter, not Formatter.nvim
vim.cmd [[autocmd BufWritePre *.elm lua vim.lsp.buf.format()]]

