call plug#begin(stdpath('data'). '/plugged')

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-unimpaired'
Plug 'thinca/vim-visualstar'

Plug 'farmergreg/vim-lastplace'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

if (has('nvim'))
  Plug 'nvim-lua/popup.nvim'
  Plug 'nvim-lua/plenary.nvim'

  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make', 'branch': 'main' }

  " LSP, Syntax + diagnostics
  Plug 'neovim/nvim-lspconfig'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

  " Formatting of code
  Plug 'mhartington/formatter.nvim'

  " Colours
  Plug 'folke/lsp-colors.nvim', { 'branch': 'main' }
  Plug 'tjdevries/colorbuddy.vim'
  Plug 'Th3Whit3Wolf/onebuddy', { 'branch': 'main' }


  " Snippets
  " Plug 'hrsh7th/vim-vsnip'
  " Plug 'hrsh7th/vim-vsnip-integ'

  " cmp (auto completion)
  Plug 'hrsh7th/cmp-nvim-lsp', { 'branch': 'main' }
  Plug 'hrsh7th/cmp-buffer', { 'branch': 'main' }
  Plug 'hrsh7th/cmp-vsnip', { 'branch': 'main' }
  Plug 'hrsh7th/cmp-path', { 'branch': 'main' }
  Plug 'hrsh7th/nvim-cmp', {'branch': 'main'}
  Plug 'hrsh7th/cmp-nvim-lua', { 'branch': 'main' }
  Plug 'saadparwaiz1/cmp_luasnip'
  Plug 'L3MON4D3/LuaSnip'


  " Misc
  Plug 'hoob3rt/lualine.nvim'
  Plug 'kassio/neoterm'
  Plug 'ojroques/vim-oscyank'
  Plug 'andymass/vim-matchup'

  " Building vim plugins + lua things
  Plug 'folke/lua-dev.nvim'

  Plug 'numToStr/FTerm.nvim'
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
colorscheme onebuddy

" this is the same as IncSearch in the onebuddy color theme
highlight Search guifg=#fafafa guibg=#4078f2 guisp=none

" Controls the floating window when your cursor is on an error
highlight DiagnosticFloatingInfo guifg=#000000 guisp=none
highlight DiagnosticFloatingWarn guifg=#000000 guisp=none
highlight DiagnosticFloatingHint guifg=#000000 guisp=none

" Controls the rendering of the code to highlight the issue
highlight DiagnosticUnderlineInfo cterm=underline guisp=black gui=underline
highlight DiagnosticUnderlineHint cterm=underline guisp=black gui=underline

" Controls the colour in the lualine block.
highlight DiagnosticHint guifg=black
highlight DiagnosticInfo guifg=black
highlight DiagnosticWarn guifg=black

" Do not autowrap comments onto the next line
set formatoptions-=t

