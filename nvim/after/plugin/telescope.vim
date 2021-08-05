nnoremap <silent> <leader>t <cmd>lua require('telescope.builtin').find_files({hidden = true})<CR>
nnoremap <silent> ;r <Cmd>Telescope live_grep<CR>
nnoremap <silent> \\ <Cmd>Telescope buffers<CR>

lua <<EOF
local actions = require('telescope.actions')

require('telescope').setup {
  defaults = {
    file_ignore_patterns = {"^node_modules/", "^.git/"},
    mappings = {
      n = {
        ["q"] = actions.close
      },
    },
  },
}
EOF
