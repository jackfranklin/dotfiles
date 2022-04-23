let g:ackprg = 'rg --vimgrep --smart-case'

" If no word, use whatever the cursor is on
let g:ack_use_cword_for_empty_search = 1

nnoremap <leader>/ :Ack!<Space>
