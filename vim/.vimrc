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
"set cursorline

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

colorscheme solarized
set background=dark

set t_Co=256 " 256 colors

" highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

"remove all trailing whitespace with ,W
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<cr>

" reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv

" ruby path if you are using rbenv
" http://stackoverflow.com/questions/9341768/vim-response-quite-slow
let g:ruby_path = system('echo $HOME/.rbenv/shims')

" Easy window navigation
" http://nvie.com/posts/how-i-boosted-my-vim/
" Vim + Tmux splits integration
" stolen from https://github.com/pengwynn/dotfiles/blob/master/vim/vim.symlink/tmux.vim

au WinEnter * let g:tmux_is_last_pane = 0

" Like `wincmd` but also change tmux panes instead of vim windows when needed.
function! TmuxWinCmd(direction)
  let nr = winnr()
  let tmux_last_pane = (a:direction == 'p' && g:tmux_is_last_pane)
  if !tmux_last_pane
    " try to switch windows within vim
    exec 'wincmd ' . a:direction
  endif
  " Forward the switch panes command to tmux if:
  " a) we're toggling between the last tmux pane;
  " b) we tried switching windows in vim but it didn't have effect.
  if tmux_last_pane || nr == winnr()
    let cmd = 'tmux select-pane -' . tr(a:direction, 'phjkl', 'lLDUR')
    call system(cmd)
    " redraw! " because `exec` fucked up the screen. why is this needed?? arrghh
    let g:tmux_is_last_pane = 1
  else
    let g:tmux_is_last_pane = 0
  endif
endfunction


" navigate between split windows/tmux panes
" nmap <C-j> :call TmuxWinCmd('j')<cr>
" nmap <C-k> :call TmuxWinCmd('k')<cr>
" nmap <C-h> :call TmuxWinCmd('h')<cr>
" nmap <C-l> :call TmuxWinCmd('l')<cr>

" nmap <c-\> :call TmuxWinCmd('p')<cr>
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

"folds
set foldmethod=manual

" make it do . in visual mode
:vnoremap . :norm.<CR>

" auto load files if vim detects they have been changed outside of Vim
set autoread


" fix slight delay after pressing ESC then O
" http://ksjoberg.com/vim-esckeys.html
" set noesckeys
set timeout timeoutlen=1000 ttimeoutlen=100

" command T shortcuts
" temporarily swapped to Ctrl P to try it out
" map <leader>t :CommandT<cr>
" map <leader>cf :CommandTFlush<cr>
map <leader>t :CtrlP<cr>

" status bar
set statusline=%F%m%r%h%w\  "fullpath and status modified sign
set statusline+=\ [%l\/%L:\%v] "line number and column number

" navigating tabs
nnoremap th  :tabfirst<CR>
nnoremap tj  :tabnext<CR>
nnoremap tk  :tabprev<CR>
nnoremap tl  :tablast<CR>
nnoremap tt  :tabedit<Space>
nnoremap tn  :tabnext<Space>
nnoremap tm  :tabm<Space>
nnoremap td  :tabclose<CR>

" :W to save, :Q to quit (should be default)
:command W w
:command Q q

" make K split lines (opposite of J)
" http://www.stanford.edu/~jacobm/vim.html
nmap K i<cr><esc>k$

" Don't add the comment prefix when I hit enter or o/O on a comment line.
" https://github.com/r00k/dotfiles/blob/master/vimrc
set formatoptions-=or

" rename the current file
" https://github.com/r00k/dotfiles/blob/master/vimrc
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
map <Leader>n :call RenameFile()<cr>

" swap between paste mode or not with ,p
nnoremap <Leader>p :set invpaste paste?<CR>
set pastetoggle=<Leader>p
