-- TODO: convert these to use NeoVim API methods directly.
vim.api.nvim_exec(
  [[
" ACK (well, Ag)
let g:ackprg = 'ag --vimgrep --smart-case'

"" nnoremap <CR> :noh<CR><CR>

" new file in current directory
map <Leader>nf :e <C-R>=expand("%:p:h") . "/" <CR>
map <leader>v :vsplit<CR>

nnoremap <silent> <PageUp> :tabprevious<CR>
nnoremap <silent> <PageDown> :tabnext<CR>
tnoremap <PageUp> <C-\><C-n>:tabprevious<CR>
tnoremap <PageDown> <C-\><C-n>:tabnext<CR>

noremap H ^
noremap L $
noremap Y y$

" http://blog.petrzemek.net/2016/04/06/things-about-vim-i-wish-i-knew-earlier/
" better jk normally but don't remap when it's called with a count
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" global clipboard
vnoremap <leader>8 "*y
vnoremap <leader>9 "*p
nnoremap <leader>8 "*p

" More undo break points in insert mode
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv


nnoremap <S-Left> :vertical resize-5<CR>
nnoremap <S-Right> :vertical resize+5<CR>
tnoremap <S-Left> :vertical resize-5<CR>
tnoremap <S-Right> :vertical resize+5<CR>
inoremap <S-Left> :vertical resize-5<CR>
inoremap <S-Right> :vertical resize+5<CR>

nnoremap <S-Up> :resize-5<CR>
nnoremap <S-Down> :resize+5<CR>
tnoremap <S-Up> :resize-5<CR>
tnoremap <S-Down> :resize+5<CR>
inoremap <S-Up> :resize-5<CR>
inoremap <S-Down> :resize+5<CR>

inoremap <S-Tab> <C-x><C-l>

tnoremap <Esc> <C-\><C-n>
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l
	]],
  false
)

vim.api.nvim_set_keymap("n", "gp", ":cnext<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "gP", ":cprev<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Space><Space>", ":noh<CR>", { noremap = true })

-- Map <CR> to ciw, but avoid certain buffers.
local augroup = vim.api.nvim_create_augroup("EnterRemap", {})
vim.api.nvim_clear_autocmds({ group = augroup })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  group = augroup,
  callback = function(data)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = data.buf })
    -- acwrite is the buftype for oil.nvim
    if buftype == "quickfix" or buftype == "acwrite" or buftype == "terminal" then
      return
    end
    vim.api.nvim_buf_set_keymap(data.buf, "n", "<CR>", "ciw", { noremap = true })
  end,
})

-- Taken from https://stackoverflow.com/questions/16678661/how-can-i-delete-the-current-file-in-vim
local function confirm_and_delete_buffer()
  local confirm = vim.fn.confirm("Delete buffer and file?", "&Yes\n&No", 2)

  if confirm == 1 then
    os.remove(vim.fn.expand("%"))
    vim.api.nvim_buf_delete(0, { force = true })
  end
end
vim.keymap.set("n", "<leader>df", confirm_and_delete_buffer)
