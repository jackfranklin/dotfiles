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

local defaultBuild = Terminal:new({
  cmd = "autoninja -C out/Default && exit",
  direction = "float",
  float_opts = {
    width = function(term)
      local width = math.ceil(vim.o.columns / 4)
      term.float_opts.col = vim.o.columns - width
      return width
    end,
    height = function(term)
      local height = 15
      term.float_opts.row = vim.o.lines - height
      return height
    end,
  },
  close_on_exit = true,
  on_open = function(term)
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  end,
})
function DefaultBuildToggle()
  defaultBuild:toggle()
end

local fastBuild = Terminal:new({
  cmd = "autoninja -C out/Fast && exit",
  direction = "float",
  float_opts = {
    width = function(term)
      local width = math.ceil(vim.o.columns / 4)
      term.float_opts.col = vim.o.columns - width
      return width
    end,
    height = function(term)
      local height = 15
      term.float_opts.row = vim.o.lines - height
      return height
    end,
  },
  close_on_exit = true,
  on_open = function(term)
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  end,
})
function FastBuildToggle()
  fastBuild:toggle()
end

vim.api.nvim_set_keymap("n", "<leader>ad", "<cmd>lua DefaultBuildToggle()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>af", "<cmd>lua FastBuildToggle()<CR>", { noremap = true, silent = true })
