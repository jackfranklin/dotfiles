vim.o.termguicolors = true
vim.o.autoread = true
vim.o.switchbuf = "useopen,usetab"
vim.o.laststatus = 3

-- Indents
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.autoindent = true

-- Do not autowrap comments onto the next line
vim.opt.formatoptions:remove("t")

vim.o.inccommand = "split"

-- Search settings
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.scrolloff = 5
vim.o.gdefault = true
vim.o.ignorecase = true

vim.o.swapfile = false
vim.opt.wildignore:append({ "*.o", "*.obj", ".git", "node_modules", "_site", "*.class", "*.zip", "*.aux" })

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true

vim.o.ttimeoutlen = 1

-- Trailing whitespace
vim.o.list = true
vim.o.listchars = "tab:»·,trail:·"

vim.g.mapleader = " "

vim.o.splitbelow = true
vim.o.splitright = true

-- Automatically rebalance windows on resize
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd("wincmd =")
  end,
})

-- Don't add the comment prefix when pressing enter or o/O on a comment line
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})

-- Better wrapping
vim.o.breakindent = true
vim.o.breakindentopt = "shift:2"

-- Eta templates: use HTML highlighting (no dedicated TS parser available)
vim.filetype.add({
  extension = {
    eta = "html",
  },
})

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
