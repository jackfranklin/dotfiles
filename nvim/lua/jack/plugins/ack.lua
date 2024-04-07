vim.api.nvim_exec(
  [[
let g:ackprg = 'rg --vimgrep --smart-case -g "!node_modules/" '

" If no word, use whatever the cursor is on
let g:ack_use_cword_for_empty_search = 1
]],
  false
)

vim.keymap.set("n", "<leader>/", ":Ack!<Space>", { desc = "Search with Ack!" })
