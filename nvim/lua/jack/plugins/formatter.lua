local M = {}
M.setup = function(config)
  local ReturnModule = {}

  local prettier_path = config.prettier_path

  local function create_prettier_formatter()
    if prettier_path == nil then
      return function()
        return nil
      end
    end

    local prettier_formatter = function()
      return {
        exe = prettier_path,
        args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
        stdin = true,
      }
    end

    if vim.fn.executable("prettierd") == 1 then
      prettier_formatter = function()
        return {
          exe = "prettierd",
          args = { vim.api.nvim_buf_get_name(0) },
          stdin = true,
        }
      end
    end

    return prettier_formatter
  end

  ReturnModule.configure_formatters = function()
    local formatter_filetypes = {
      javascript = {},
      javascriptreact = {},
      typescriptreact = {},
      svelte = {},
      typescript = {},
      css = {},
      lua = {
        require("formatter.filetypes.lua").stylua,
      },
      rust = {
        function()
          return {
            exe = "rustfmt",
            args = { "--emit=stdout", "--edition=2021" },
            stdin = true,
          }
        end,
      },
    }

    local prettier_formatter = create_prettier_formatter()
    table.insert(formatter_filetypes.javascript, prettier_formatter)
    table.insert(formatter_filetypes.svelte, prettier_formatter)
    table.insert(formatter_filetypes.css, prettier_formatter)
    table.insert(formatter_filetypes.typescript, prettier_formatter)
    table.insert(formatter_filetypes.javascriptreact, prettier_formatter)
    table.insert(formatter_filetypes.typescriptreact, prettier_formatter)

    require("formatter").setup({
      -- logging = false,
      filetype = formatter_filetypes,
    })

    -- TODO: better way to turn formatter on automatically - check if at least one formatter is defined for the current file type?
    vim.api.nvim_exec(
      [[
augroup FormatAutogroup
autocmd!
autocmd BufWritePost *.cjs,*.mjs,*.js,*.svelte,*.ts,*.rs,*.css,*.jsx,*.tsx,*.lua FormatWrite
augroup END
]],
      true
    )

    -- Run Elm-format via the LSP formatter, not Formatter.nvim
    vim.cmd([[autocmd BufWritePre *.elm lua vim.lsp.buf.format()]])
  end

  ReturnModule.create_prettier_formatter = create_prettier_formatter

  return ReturnModule
end

return M
