lua require('jack.init').init()

set termguicolors

filetype plugin indent on

so ~/.config/nvim/defaults.vim
so ~/.config/nvim/maps.vim

lua require('jack.theme')

" Do not autowrap comments onto the next line
set formatoptions-=t

set switchbuf=useopen,usetab

inoremap <S-Tab> <C-x><C-l>
set laststatus=3
