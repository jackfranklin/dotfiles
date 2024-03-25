require("mini.indentscope").setup({
  options = {
    try_as_border = true,
  },
})

-- Disable indents when in terminal, executor windows (nofile) and help
local augroup = vim.api.nvim_create_augroup("DisableIndent", {})
vim.api.nvim_clear_autocmds({ group = augroup })
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  group = augroup,
  callback = function(data)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = data.buf })
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = data.buf })
    if vim.tbl_contains({ "terminal", "help", "nofile" }, buftype) or vim.tbl_contains({ "css" }, filetype) then
      vim.b.miniindentscope_disable = true
    end
  end,
})
