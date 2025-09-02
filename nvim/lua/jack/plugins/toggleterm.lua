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
  persist_mode = true,
  insert_mappings = false,
  open_mappings = false,
  open_mapping = nil,
})

vim.api.nvim_exec2(
  [[
autocmd BufEnter * if &filetype == 'toggleterm' | :set cursorline | endif
autocmd BufLeave * if &filetype == 'toggleterm' | :set nocursorline | endif
]],
  { output = false }
)
local Terminal = require("toggleterm.terminal").Terminal
local side_terminal = Terminal:new({
  direction = "vertical",
  hidden = true,
  close_on_exit = true,
  start_in_insert = true,
})

function SideTermToggle()
  side_terminal:toggle(vim.o.columns * 0.3)
end

vim.keymap.set("n", "<leader>pt", "<cmd>lua SideTermToggle()<CR>", {
  noremap = true,
  silent = true,
  desc = "toggle side terminal",
})
