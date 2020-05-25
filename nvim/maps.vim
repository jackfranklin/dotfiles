" ACK (well, Ag)
let g:ackprg = 'ag --vimgrep --smart-case'
nnoremap \ :Ack!<SPACE>
nnoremap K :Ack! "\b<C-R><C-W>\b"<CR>:cw<CR>

nnoremap <CR> :noh<CR><CR>

" new file in current directory
map <Leader>nf :e <C-R>=expand("%:p:h") . "/" <CR>

map <leader>v :vsplit<CR>

noremap H ^
noremap L $

" http://blog.petrzemek.net/2016/04/06/things-about-vim-i-wish-i-knew-earlier/
" better jk normally but don't remap when it's called with a count
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" FZF.vim
nnoremap <leader>t :Files<cr>
nnoremap <leader>b :Buffers<cr>


" global clipboard
vnoremap <leader>8 "*y
vnoremap <leader>9 "*p
nnoremap <leader>8 "*p

" terryma/expand-region
map <Right> <Plug>(expand_region_expand)
map <Left> <Plug>(expand_region_shrink)

nnoremap <leader>z za<CR>
