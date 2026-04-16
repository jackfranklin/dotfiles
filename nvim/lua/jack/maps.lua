vim.keymap.set("n", "<leader>nf", ':e <C-R>=expand("%:p:h") . "/" <CR>', { desc = "Create [n]ew [f]ile in directory" })
vim.keymap.set("n", "<leader>v", ":vsplit<CR>", { desc = ":vsplit" })

-- ACK (well, Ag)
vim.g.ackprg = "ag --vimgrep --smart-case"

vim.keymap.set("n", "<PageUp>", ":tabprevious<CR>", { silent = true })
vim.keymap.set("n", "<PageDown>", ":tabnext<CR>", { silent = true })
vim.keymap.set("t", "<PageUp>", [[<C-\><C-n>:tabprevious<CR>]])
vim.keymap.set("t", "<PageDown>", [[<C-\><C-n>:tabnext<CR>]])

vim.keymap.set({ "n", "x", "o" }, "H", "^")
vim.keymap.set({ "n", "x", "o" }, "L", "$")
vim.keymap.set({ "n", "x", "o" }, "Y", "y$")

-- http://blog.petrzemek.net/2016/04/06/things-about-vim-i-wish-i-knew-earlier/
-- better jk normally but don't remap when it's called with a count
vim.keymap.set({ "n", "x", "o" }, "j", function() return vim.v.count == 0 and "gj" or "j" end, { expr = true, silent = true })
vim.keymap.set({ "n", "x", "o" }, "k", function() return vim.v.count == 0 and "gk" or "k" end, { expr = true, silent = true })

-- More undo break points in insert mode
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", "!", "!<c-g>u")
vim.keymap.set("i", "?", "?<c-g>u")

vim.keymap.set({ "n", "t", "i" }, "<S-Left>", ":vertical resize-5<CR>")
vim.keymap.set({ "n", "t", "i" }, "<S-Right>", ":vertical resize+5<CR>")
vim.keymap.set({ "n", "t", "i" }, "<S-Up>", ":resize-5<CR>")
vim.keymap.set({ "n", "t", "i" }, "<S-Down>", ":resize+5<CR>")

-- Mapping a single Esc messes up Neovim within a terminal which is useful
-- sometimes for Git based things
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]])
vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]])
vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]])
vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]])
vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]])
vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]])
vim.keymap.set("n", "<Esc>", ":noh<CR>")

vim.keymap.set("n", "cn", ":cnext<CR>", { desc = "Quickfix [n]ext" })
vim.keymap.set("n", "cp", ":cprev<CR>", { desc = "Quickfix [p]revious" })

-- Highlight text when yanking it
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Map <CR> to ciw, but avoid certain buffers.
local augroup = vim.api.nvim_create_augroup("EnterRemap", {})
vim.api.nvim_clear_autocmds({ group = augroup })
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  group = augroup,
  callback = function(data)
    if data.file == "" then
      return
    end
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = data.buf })
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = data.buf })
    if buftype == "quickfix" or buftype == "acwrite" or buftype == "terminal" or buftype == "nowrite" then
      return
    end
    if filetype == "fugitiveblame" or filetype == "codecompanion" then
      return
    end
    vim.keymap.set("n", "<CR>", "ciw", { buffer = data.buf })
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
vim.keymap.set("n", "<leader>bd", confirm_and_delete_buffer, { desc = "[b]uffer [d]elete [FROM DISK]" })

local function rename_buffer()
  -- Get the current filename and the directory path.
  local old_name = vim.fn.expand("%:t")
  local current_dir = vim.fn.fnamemodify(vim.fn.expand("%"), ":p:h")

  -- Get the new name from the user.
  vim.ui.input({
    prompt = "New name:",
    default = old_name,
  }, function(new_name)
    -- Check if a new name was provided and if it's different from the old name.
    if new_name and new_name ~= "" and new_name ~= old_name then
      local full_path = current_dir .. "/" .. new_name
      vim.cmd("saveas " .. full_path)
    end
  end)
end
vim.keymap.set("n", "<leader>br", rename_buffer, { desc = "[b]uffer [r]ename" })

local function clear_all_open_buffers()
  local bufs = vim.api.nvim_list_bufs()
  for _, i in ipairs(bufs) do
    vim.api.nvim_buf_delete(i, {})
  end
end

vim.keymap.set("n", "<leader>bc", clear_all_open_buffers, { desc = "[b]uf [c]lear: clear all neovim buffers" })

vim.keymap.set("n", "<leader>wl", "<C-w>L", {
  desc = "Move [w] to right hand split",
})
