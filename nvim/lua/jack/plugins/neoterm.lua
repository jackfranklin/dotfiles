vim.api.nvim_exec(
  [[
autocmd BufEnter * if &filetype == 'neoterm' | :startinsert | endif
]],
  false
)
vim.api.nvim_set_keymap("n", "gt", ":tab Tnew<CR>", { noremap = true })
