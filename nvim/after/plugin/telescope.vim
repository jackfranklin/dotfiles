nnoremap <silent> <leader>t <cmd>lua require('telescope.builtin').find_files({hidden = true})<CR>
nnoremap <silent> <leader>r <Cmd>Telescope live_grep<CR>
nnoremap <silent> <leader>b <Cmd>Telescope buffers<CR>
nnoremap <silent> <leader>s <Cmd>Telescope lsp_document_symbols<CR>

lua <<EOF
local actions = require('telescope.actions')

require('telescope').setup {
  pickers = {
      find_files = {
        previewer = false,
      },
      file_browser = {
        previewer = false,
      }
    },
  defaults = {
    file_ignore_patterns = {"^node_modules/", "^.git/"},
    disable_devicons = true,
    mappings = {
      n = {
        ["q"] = actions.close
      },
    },
  },
}
EOF
