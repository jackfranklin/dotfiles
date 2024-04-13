require("mini.indentscope").setup({
  options = {
    try_as_border = true,
  },
})

-- Disable by default in both buffers and terminal (which fzf-lua uses).
-- Because the setting is per buffer this has to be done in an autocmd.
local augroup = vim.api.nvim_create_augroup("DisableIndent", {})
vim.api.nvim_clear_autocmds({ group = augroup })
vim.api.nvim_create_autocmd({ "TermEnter" }, {
  group = augroup,
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  group = augroup,
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})

vim.keymap.set("n", "<leader>si", function()
  if vim.b.miniindentscope_disable == true then
    vim.b.miniindentscope_disable = false
  else
    vim.b.miniindentscope_disable = true
  end
end, { desc = "[set] indentlines on/off" })
