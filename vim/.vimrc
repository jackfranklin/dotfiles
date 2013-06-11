" pathogen plugins
call pathogen#infect()
call pathogen#helptags()

" status bar
set statusline=%F%m%r%h%w\  "fullpath and status modified sign
set statusline+=\ %y "filetype
set statusline+=%=
set statusline+=\ [%l\/%L:\%v] "line number and column number

" auto load files if vim detects they have been changed outside of Vim
set autoread

" fix slight delay after pressing ESC then O
" http://ksjoberg.com/vim-esckeys.html
" set noesckeys
set timeout timeoutlen=1000 ttimeoutlen=100

" it's 2013 yo
set nocompatible

" allow unsaved background buffers and remember marks/undo for them
set hidden

" remember more commands and search history
set history=10000

" spaces > tabs.
" there, I said it.
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent

set laststatus=2

" break properly, don't split words
set linebreak

" use matchit plugin
" required for rubyblocks plugin
runtime macros/matchit.vim

"folds
set foldmethod=manual

" show search matches as I type
set showmatch
set incsearch
set hlsearch

" make searches case-sensitive only if they contain upper-case characters
set ignorecase smartcase

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
filetype plugin indent on

" use emacs-style tab completion when selecting files, etc
set wildmode=longest,list

" make tab completion for files/buffers act like bash
set wildmenu

" leader key
let mapleader=","

" ignore git, npm modules and jekyll _site
set wildignore+=*.o,*.obj,.git,node_modules,_site

" I like line numbers
set number

" pretty colours
colorscheme solarized
set background=dark
set t_Co=256


" highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" TODO: maybe move this into its own file and source it?
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

" :W to save, :Q to quit (should be default)
command! W w
command! Q q


" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright


" ~~~ MAPPINGS BELOW ~~~
" Make j/k move to next visual line instead of physical line
" http://yubinkim.com/?p=6
nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j

" make the TCOmment toggle <leader>c
map <leader>c gcc

"remove all trailing whitespace with ,W
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<cr>

" reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv



" navigate between split windows/tmux panes
" nmap <C-j> :call TmuxWinCmd('j')<cr>
" nmap <C-k> :call TmuxWinCmd('k')<cr>
" nmap <C-h> :call TmuxWinCmd('h')<cr>
" nmap <C-l> :call TmuxWinCmd('l')<cr>
" nmap <c-\> :call TmuxWinCmd('p')<cr>
" above disabled as I don't use split Tmux much ATM
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" make it do . in visual mode
vnoremap . :norm.<CR>

" control P
map <leader>t :CtrlP<cr>
map <leader>cf :CtrlPClearCache<cr>
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\'

" navigating tabs
nnoremap th  :tabfirst<CR>
nnoremap tj  :tabnext<CR>
nnoremap tk  :tabprev<CR>
nnoremap tl  :tablast<CR>
nnoremap tt  :tabedit<Space>
nnoremap tn  :tabnext<Space>
nnoremap tm  :tabm<Space>
nnoremap td  :tabclose<CR>

" Don't add the comment prefix when I hit enter or o/O on a comment line.
" https://github.com/r00k/dotfiles/blob/master/vimrc
" TODO: doesn't seem to be working? - was this wrong?
" set formatoptions-=or

" TODO: abstract big functions into own files?
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

"create new file in CWD of current file
function! NewFileInCurDir()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    " create new file
    exec ':e ' . new_name
    " clear it out (it uses the contents of the old file for an unknown
    " reason)
    exec 'normal! ggVGd'
    " save it
    exec ':saveas ' . new_name
    redraw!
  endif
endfunction
map <Leader>nf :call NewFileInCurDir()<cr>

" swap between paste mode or not with ,p
nnoremap <Leader>p :set invpaste paste?<CR>
set pastetoggle=<Leader>p


" easy vimrc editing
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" scratchpad
nnoremap <leader>sp :vsplit ~/dotfiles/scratchpad<cr>

" project notes
function! OpenProjectNotes()
  let directory = getcwd()
  let filename = '_projectnotes.txt'
  exec ':vsplit ' . directory . '/' . filename
endfunction

nnoremap <leader>pn :call OpenProjectNotes()<cr>

map <leader>nt :NERDTreeToggle<cr>

" bubble lines up and down
" http://vimcasts.org/episodes/bubbling-text/
nmap _ ddkP
nmap - ddp

" insert blank line above
nmap <leader>bO O<Esc>j
" insert blank line below
nmap <leader>bo o<Esc>k
