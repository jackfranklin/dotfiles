call plug#begin(stdpath('data'). '/plugged')

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-eunuch'
Plug 'terryma/vim-multiple-cursors'

Plug 'dag/vim-fish'

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'Shougo/neosnippet.vim'
endif

Plug 'HerringtonDarkholme/yats.vim'
Plug '/othree/yajs.vim'

Plug 'andys8/vim-elm-syntax'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'dense-analysis/ale'
Plug 'christoomey/vim-tmux-navigator'

call plug#end()

filetype plugin indent on

set statusline=%F%m%r%h%w\  "fullpath and status modified sign
set statusline+=\ %y "filetype
set statusline+=\ %{fugitive#statusline()}
" this line below pushes everything below it to the right hand side
set statusline+=%=
set statusline+=\%l

set gdefault
set autoread

set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent

set incsearch
set hlsearch
set scrolloff=5

let mapleader=","

set number
set relativenumber
set cursorline
autocmd FileType * setlocal formatoptions-=r formatoptions-=o

nnoremap <CR> :noh<CR><CR>
set splitbelow
set splitright

" new file in current directory
map <Leader>nf :e <C-R>=expand("%:p:h") . "/" <CR>

map <leader>v :vsplit<CR>

" Don't add the comment prefix when I hit enter or o/O on a comment line.
" autocmd FileType * setlocal formatoptions-=r formatoptions-=o

noremap H ^
noremap L $

" http://blog.petrzemek.net/2016/04/06/things-about-vim-i-wish-i-knew-earlier/
" better jk normally but don't remap when it's called with a count
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" FZF.vim
nnoremap <leader>t :Files<cr>
nnoremap <leader>b :Buffers<cr>

highlight CursorLine cterm=none ctermbg=16

highlight Comment cterm=italic

let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0

let g:ale_fix_on_save = 1

let g:neosnippet#snippets_directory = '~/.config/nvim/UltiSnips'
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)

let g:neosnippet#disable_runtime_snippets = {
\   '_' : 1,
\ }

highlight PMenuSel ctermfg=0 ctermbg=13
highlight PMenu ctermfg=255 ctermbg=0
highlight MatchParen ctermfg=255 ctermbg=240
highlight ALEError ctermbg=none cterm=underline ctermfg=1
