set completeopt=menuone,noselect

lua << EOF
require'compe'.setup({
  autocomplete = false,
  min_length = 2,
  preselect = "always",
  enabled = true,
  source = {
    nvim_lsp = true,
    buffer = true,
    path = true,
    vsnip = true,
  },
})
EOF

inoremap <silent><expr> <C-space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
