call plug#begin(stdpath('data'). '/plugged')

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-unimpaired'
Plug 'gorkunov/smartpairs.vim'
" Plug 'thinca/vim-visualstar'
" Plug 'Konfekt/FastFold'
" Plug 'junegunn/goyo.vim'

Plug 'christoomey/vim-tmux-navigator'
Plug 'christoomey/vim-tmux-runner'
Plug 'mileszs/ack.vim'

" THEMES
Plug 'lifepillar/vim-solarized8'

if (has('nvim'))
  Plug 'neovim/nvim-lspconfig'
  Plug 'glepnir/lspsaga.nvim', { 'branch': 'main' }
  Plug 'nvim-lua/popup.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'folke/lsp-colors.nvim', { 'branch': 'main' }
  Plug 'folke/trouble.nvim', { 'branch': 'main' }
  Plug 'tjdevries/colorbuddy.vim'
  Plug 'Th3Whit3Wolf/onebuddy', { 'branch': 'main' }
  Plug 'JoosepAlviste/nvim-ts-context-commentstring', { 'branch': 'main' }
  Plug 'mhartington/formatter.nvim'
end

call plug#end()


if (has('termguicolors'))
  set termguicolors
endif

filetype plugin indent on

so ~/.config/nvim/defaults.vim
" so ~/.config/nvim/coc.vim
" so ~/.config/nvim/fzf.vim
" so ~/.config/nvim/highlights.vim
so ~/.config/nvim/maps.vim

" So you can run :call SyntaxItem() to see what the syntax is
function! SyntaxItem()
  echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
        \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
        \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"
endfunction

" set background=dark
" colorscheme solarized8

set background=light
colorscheme onebuddy

set foldlevel=99
set foldmethod=indent

nnoremap <silent> <C-p> <cmd>Lspsaga diagnostic_jump_prev<CR>
nnoremap <silent> <C-n> <cmd>Lspsaga diagnostic_jump_next<CR>

