call plug#begin(stdpath('data'). '/plugged')

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-unimpaired'
Plug 'thinca/vim-visualstar'

Plug 'mileszs/ack.vim'

Plug 'farmergreg/vim-lastplace'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

if (has('nvim'))
  Plug 'nvim-lua/popup.nvim'
  Plug 'nvim-lua/plenary.nvim'

  Plug 'kylechui/nvim-surround'
  Plug 'MunifTanjim/nui.nvim'

  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make', 'branch': 'main' }

  " LSP, Syntax + diagnostics
  Plug 'neovim/nvim-lspconfig'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  " Loading status of LSP servers
  Plug 'j-hui/fidget.nvim'

  " Formatting of code
  Plug 'mhartington/formatter.nvim'

  " Colours
  Plug 'folke/lsp-colors.nvim', { 'branch': 'main' }
  Plug 'tjdevries/colorbuddy.vim'
  Plug 'Th3Whit3Wolf/onebuddy', { 'branch': 'main' }


  " Snippets
  Plug 'L3MON4D3/LuaSnip'

  " cmp (auto completion)
  Plug 'hrsh7th/cmp-nvim-lsp', { 'branch': 'main' }
  Plug 'hrsh7th/cmp-buffer', { 'branch': 'main' }
  Plug 'hrsh7th/cmp-vsnip', { 'branch': 'main' }
  Plug 'hrsh7th/cmp-path', { 'branch': 'main' }
  Plug 'hrsh7th/nvim-cmp', {'branch': 'main'}
  Plug 'hrsh7th/cmp-nvim-lua', { 'branch': 'main' }
  Plug 'saadparwaiz1/cmp_luasnip'


  " Misc
  Plug 'kassio/neoterm'
  Plug 'ojroques/vim-oscyank'

  " Building vim plugins + lua things
  " Plug 'folke/lua-dev.nvim'
  Plug 'numToStr/FTerm.nvim'

  Plug 'rmagatti/auto-session'
  Plug 'ldelossa/buffertag', { 'branch': 'main' }
  Plug 'SmiteshP/nvim-navic'

  Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

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

set background=light
" colorscheme onebuddy
lua require('jack.theme')

" Do not autowrap comments onto the next line
set formatoptions-=t

set switchbuf=useopen,usetab

inoremap <S-Tab> <C-x><C-l>
set laststatus=3
