call pathogen#infect()
call pathogen#helptags()

set nocompatible
" allow unsaved background buffers and remember marks/undo for them
set hidden
" remember more commands and search history
set history=10000
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set laststatus=2
set showmatch
set incsearch
set hlsearch
" make searches case-sensitive only if they contain upper-case characters
set ignorecase smartcase
" highlight current line
set cursorline
" set showtabline=2
" Prevent Vim from clobbering the scrollback buffer. See
" http://www.shallowsky.com/linux/noaltscreen.html
set t_ti= t_te=
" keep more context when scrolling off the end of a buffer
set scrolloff=3
" Store temporary files in a central spot
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
" display incomplete commands
set showcmd
" Enable highlighting for syntax
syntax on
" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on
" use emacs-style tab completion when selecting files, etc
set wildmode=longest,list
" make tab completion for files/buffers act like bash
set wildmenu
let mapleader=","


:set wildignore+=*.o,*.obj,.git,node_modules

" Make j/k move to next visual line instead of physical line
" http://yubinkim.com/?p=6
nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j

" I like line numbers
set number

" make the TCOmment toggle <leader>c
map <leader>c gcc

" vim pipe filetypes
" screw local leader, just map it to regular leader
map <leader>r <localleader>r
map <leader>p <localleader>p
autocmd FileType javascript let b:vimpipe_command='node <(cat)'

" highlight trailing whitespace
" http://nvie.com/posts/how-i-boosted-my-vim/
set list
set listchars=trail:.,extends:#,nbsp:.

" ruby path if you are using rbenv
" http://stackoverflow.com/questions/9341768/vim-response-quite-slow
let g:ruby_path = system('echo $HOME/.rbenv/shims')

" Easy window navigation
" http://nvie.com/posts/how-i-boosted-my-vim/
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

"folds
set foldmethod=syntax
set foldlevelstart=20

" make it do . in visual mode
:vnoremap . :norm.<CR>

" auto load files if vim detects they have been changed outside of Vim
set autoread
