vim.api.nvim_exec(
  [[
filetype plugin indent on
set termguicolors
set autoread

" Do not autowrap comments onto the next line
set formatoptions-=t

set switchbuf=useopen,usetab
set laststatus=3

" INDENTS + STUFF
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent

set inccommand=split

" SEARCH SETTINGS
set incsearch
set hlsearch
set scrolloff=5
set gdefault
set ignorecase

set noswapfile
set wildignore+=*.o,*.obj,.git,node_modules,_site,*.class,*.zip,*.aux

set number
set relativenumber
set cursorline

set ttimeoutlen=1

" TRAILING WHITESPACE
set list listchars=tab:»·,trail:·

" let mapleader=","
let mapleader = "\<Space>"

set splitbelow
set splitright

" automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

" Don't add the comment prefix when I hit enter or o/O on a comment line.
autocmd FileType * setlocal formatoptions-=r formatoptions-=o

" Better wrapping
set breakindent
set breakindentopt=shift:2

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set nofoldenable
]],
  false
)
