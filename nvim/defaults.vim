" STATUS LINE
set statusline=%F%m%r%h%w\  "fullpath and status modified sign
set statusline+=\ %y "filetype
set statusline+=\ %{fugitive#statusline()}
" this line below pushes everything below it to the right hand side
set statusline+=%=
set statusline+=\%l

set autoread

" INDENTS + STUFF
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent

set inccommand=nosplit

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

" Better default folds
set foldlevel=99
set foldmethod=indent

" Better wrapping
set breakindent
set breakindentopt=shift:2
