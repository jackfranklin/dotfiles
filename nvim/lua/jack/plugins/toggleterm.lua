require("toggleterm").setup({
  shade_terminals = false,
  highlights = {
    StatusLine = {
      -- For some reason ToggleTerm breaks the statusline by setting gui=None for highlights.
      -- So these colors are the colours from the flat_dark theme (currently the active one) to reset them back to normal.
      -- If I change theme, I likely need to come and update these!
      guifg = "#9ca3b2",
      guibg = "#1e2024",
    },
  },
})

vim.api.nvim_exec(
  [[
autocmd BufEnter * if &filetype == 'toggleterm' | :startinsert | endif
]],
  false
)
local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({
  cmd = "lazygit",
  direction = "float",
  hidden = true,
  on_open = function(term)
    vim.cmd("startinsert!")
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  end,
})
local side_terminal = Terminal:new({
  direction = "vertical",
  hidden = true,
  on_open = function(term)
    vim.cmd("startinsert!")
  end,
  close_on_exit = true,
  start_in_insert = true,
})

function LazyGitToggle()
  lazygit:toggle()
end
function SideTermToggle()
  side_terminal:toggle(vim.o.columns * 0.3)
end

vim.api.nvim_set_keymap("n", "<leader>lg", "<cmd>lua LazyGitToggle()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>pt", "<cmd>lua SideTermToggle()<CR>", { noremap = true, silent = true })
