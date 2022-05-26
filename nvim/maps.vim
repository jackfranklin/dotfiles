" ACK (well, Ag)
let g:ackprg = 'ag --vimgrep --smart-case'

nnoremap <CR> :noh<CR><CR>

" new file in current directory
map <Leader>nf :e <C-R>=expand("%:p:h") . "/" <CR>
map <leader>v :vsplit<CR>

nnoremap <PageUp> :tabprevious<CR>
nnoremap <PageDown> :tabnext<CR>
tnoremap <PageUp> <C-\><C-n>:tabprevious<CR>
tnoremap <PageDown> <C-\><C-n>:tabnext<CR>
nnoremap <C-o> :tabprevious<CR>
nnoremap <C-p> :tabnext<CR>
tnoremap <C-o> <C-\><C-n>:tabprevious<CR>
tnoremap <C-p> <C-\><C-n>:tabnext<CR>

noremap H ^
noremap L $
noremap Y y$
" http://blog.petrzemek.net/2016/04/06/things-about-vim-i-wish-i-knew-earlier/
" better jk normally but don't remap when it's called with a count
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" global clipboard
vnoremap <leader>8 "*y
vnoremap <leader>9 "*p
nnoremap <leader>8 "*p

" FOLDS
nnoremap <leader>z za<CR>

" More undo break points in insert mode
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv


nnoremap <S-Left> :vertical resize-5<CR>
nnoremap <S-Right> :vertical resize+5<CR>
tnoremap <S-Left> :vertical resize-5<CR>
tnoremap <S-Right> :vertical resize+5<CR>
inoremap <S-Left> :vertical resize-5<CR>
inoremap <S-Right> :vertical resize+5<CR>

nnoremap <S-Up> :resize-5<CR>
nnoremap <S-Down> :resize+5<CR>
tnoremap <S-Up> :resize-5<CR>
tnoremap <S-Down> :resize+5<CR>
inoremap <S-Up> :resize-5<CR>
inoremap <S-Down> :resize+5<CR>
