let g:neosnippet#snippets_directory = '~/.config/nvim/UltiSnips'
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)

let g:neosnippet#disable_runtime_snippets = {
\   '_' : 1,
\ }
