vim.g.neoterm_size = tostring(0.3 * vim.o.columns)
vim.g.neoterm_default_mod = 'botright vertical'

vim.api.nvim_create_user_command('TaskThenExit', function(input)
  local cmd = input.args
  vim.api.nvim_command(":Tnew")
  vim.api.nvim_command(":T " .. cmd .. " && exit")
end, { bang = true, nargs = '*' })
vim.api.nvim_create_user_command('TaskPersist', function(input)
  local cmd = input.args
  vim.api.nvim_command(":1T clear && " .. cmd)
end, { bang = true, nargs = '*' })

vim.api.nvim_set_keymap("n", "<leader>pe", ":TaskThenExit ",{})
vim.api.nvim_set_keymap("n", "<leader>pp", ":TaskPersist ",{})
vim.api.nvim_set_keymap("n", "<leader>pt", ":1Ttoggle<CR><ESC>",{})

