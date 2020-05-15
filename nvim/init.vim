call plug#begin(stdpath('data'). '/plugged')

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-unimpaired'
Plug 'terryma/vim-multiple-cursors'
Plug 'terryma/vim-expand-region'
Plug 'thinca/vim-visualstar'

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/neosnippet.vim'

" SYNTAXES
Plug 'othree/yajs.vim' " JavaScript
Plug 'HerringtonDarkholme/yats.vim' " TypeScript
Plug 'andys8/vim-elm-syntax'
Plug 'dag/vim-fish'
Plug 'plasticboy/vim-markdown'
Plug 'niftylettuce/vim-jinja' " Nunjucks

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'christoomey/vim-tmux-navigator'
Plug 'christoomey/vim-tmux-runner'
Plug 'mileszs/ack.vim'

" THEMES
Plug 'lifepillar/vim-solarized8'

call plug#end()

if (has('termguicolors'))
  set termguicolors
endif

filetype plugin indent on

so ~/.config/nvim/defaults.vim
so ~/.config/nvim/coc.vim
so ~/.config/nvim/fzf.vim
so ~/.config/nvim/highlights.vim
so ~/.config/nvim/maps.vim
so ~/.config/nvim/snippets.vim

" So you can run :call SyntaxItem() to see what the syntax is
function! SyntaxItem()
  echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
        \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
        \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"
endfunction

set background=dark
colorscheme solarized8

set foldlevel=99
set foldmethod=syntax
