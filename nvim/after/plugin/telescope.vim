" nnoremap <silent> <leader>t <cmd>lua require('telescope.builtin').find_files({hidden = true})<CR>
" nnoremap <silent> <leader>b <Cmd>Telescope buffers<CR>
" noremap <silent> <leader>s <Cmd>Telescope lsp_document_symbols<CR>

lua <<EOF
local has_plugins = pcall(require, 'telescope');
if not has_plugins then
  return
end
local actions = require('telescope.actions')

require('telescope').setup {
  pickers = {
    find_files = {
      previewer = false,
    },
    file_browser = {
      previewer = false,
    },
  },
  defaults = {
    file_ignore_patterns = {"^node_modules/", "^.git/"},
    disable_devicons = true,
    preview = false,
    hl_result_eol = false,
    mappings = {
      n = {
        ["q"] = actions.close
      },
    },
    layout_config = {
      horizontal = {
        height = 0.5,
      }
    },
  },
}

require('telescope').load_extension('fzf')
EOF
