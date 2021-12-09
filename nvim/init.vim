call plug#begin(stdpath('data'). '/plugged')

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-unimpaired'
Plug 'gorkunov/smartpairs.vim'
Plug 'thinca/vim-visualstar'

Plug 'christoomey/vim-tmux-navigator'
Plug 'christoomey/vim-tmux-runner'
Plug 'mileszs/ack.vim'
Plug 'farmergreg/vim-lastplace'

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
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-vsnip'
  Plug 'TimUntersberger/neogit'
  Plug 'hrsh7th/vim-vsnip'
  Plug 'hrsh7th/vim-vsnip-integ'
  Plug 'windwp/nvim-autopairs'
  Plug 'ray-x/lsp_signature.nvim'
  Plug 'hoob3rt/lualine.nvim'
  Plug 'kassio/neoterm'
  Plug 'ojroques/vim-oscyank'
end

call plug#end()


if (has('termguicolors'))
  set termguicolors
endif

filetype plugin indent on

so ~/.config/nvim/defaults.vim
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

" this is the same as IncSearch in the onebuddy color theme
highlight Search guifg=#fafafa guibg=#4078f2 guisp=none
highlight DiagnosticFloatingHint guifg=#fafafa

