call plug#begin(stdpath('data'). '/plugged')

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'lifepillar/vim-solarized8'

call plug#end()

if (has('termguicolors'))
  set termguicolors
endif

filetype plugin indent on

set background=dark
colorscheme solarized8
