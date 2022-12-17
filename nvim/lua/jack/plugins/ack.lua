vim.api.nvim_exec(
  [[
let g:ackprg = 'rg --vimgrep --smart-case'

" If no word, use whatever the cursor is on
let g:ack_use_cword_for_empty_search = 1
]],
  false
)

vim.api.nvim_set_keymap("n", "<leader>/", ":Ack!<Space>", {})
