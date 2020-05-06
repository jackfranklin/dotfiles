" Only lint when saving files
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0

" Fix on save is configured via ftplugin/*.vim for each filetype.
let g:ale_fix_on_save = 1

" So that in TypeScript (and maybe others?) there's nice completions
set omnifunc=ale#completion#OmniFunc

" Use Ctrl-e to jump to the next Ale warning/error
nmap <silent> <C-e> <Plug>(ale_next_wrap)

nnoremap <leader>h :ALEHover<CR>
nnoremap <leader>d :ALEDetail<CR>

nnoremap gd :ALEGoToDefinition<CR>

