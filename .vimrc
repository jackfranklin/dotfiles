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
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()
"remove all trailing whitespace
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<cr>

" toggle git status with Space + s
nnoremap <space>s :Gstatus<CR>


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
function TmuxWinCmd(direction)
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
nmap <C-j> :call TmuxWinCmd('j')<cr>
nmap <C-k> :call TmuxWinCmd('k')<cr>
nmap <C-h> :call TmuxWinCmd('h')<cr>
nmap <C-l> :call TmuxWinCmd('l')<cr>

" nmap <c-\> :call TmuxWinCmd('p')<cr>
" map <C-h> <C-w>h
" map <C-j> <C-w>j
" map <C-k> <C-w>k
" map <C-l> <C-w>l

"folds
" set foldmethod=indent
set foldmethod=manual

" make it do . in visual mode
:vnoremap . :norm.<CR>

" auto load files if vim detects they have been changed outside of Vim
set autoread

if has('gui_running')
  " nicer gfx settings are set in .gvimrc
else
  hi CursorLine   cterm=NONE ctermbg=234
  highlight CommandTSelection ctermbg=236
  set background=dark
endif

set t_Co=256 " 256 colors

" fix slight delay after pressing ESC then O
" http://ksjoberg.com/vim-esckeys.html
" set noesckeys
set timeout timeoutlen=1000 ttimeoutlen=100

" command T shortcuts
map <leader>t :CommandT<cr>
map <leader>cf :CommandTFlush<cr>

" status bar
set statusline=%F%m%r%h%w\  "fullpath and status modified sign
" set statusline+=%m\                "modified flag
set statusline+=\ [%l\/%L:\%v] "line number
" set statusline +=\ [col\ %v\]             "virtual column number

" navigating tabs
nnoremap th  :tabfirst<CR>
nnoremap tj  :tabnext<CR>
nnoremap tk  :tabprev<CR>
nnoremap tl  :tablast<CR>
nnoremap tt  :tabedit<Space>
nnoremap tn  :tabnext<Space>
nnoremap tm  :tabm<Space>
nnoremap td  :tabclose<CR>

"tagbar
nnoremap <silent> <Leader>T :TagbarToggle<CR>
