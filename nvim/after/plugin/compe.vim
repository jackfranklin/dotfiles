set completeopt=menuone,noselect

lua << EOF
require'compe'.setup({
  autocomplete = true,
  min_length = 3,
  preselect = 'enable',
  enabled = true,
  source = {
    path = true,
    buffer = true,
    nvim_lsp = true,
  },
})
EOF

inoremap <silent><expr> <C-space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })

