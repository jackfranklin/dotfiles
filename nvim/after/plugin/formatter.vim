lua<<EOF
require('formatter').setup({
  logging = false,
  filetype = {
    javascript = {
       function()
          return {
            exe = "./node_modules/.bin/prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
            stdin = true
          }
        end
    },
    svelte = {
       function()
          return {
            exe = "./node_modules/.bin/prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
            stdin = true
          }
        end
    },
    typescript = {
       function()
          return {
            exe = "./node_modules/.bin/prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
            stdin = true
          }
        end
    }
  }
})
vim.api.nvim_exec([[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.js,*.svelte,*.ts FormatWrite
augroup END
]], true)
EOF
