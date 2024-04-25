vim.opt.foldcolumn = "0"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""

vim.opt.foldnestmax = 3

local augroup = vim.api.nvim_create_augroup("FoldLevel", {})
vim.api.nvim_clear_autocmds({ group = augroup })
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  group = augroup,
  callback = function(data)
    print(vim.inspect(data))
    local file_name = data.file
    if string.find(file_name, ".test.", 1, true) then
      vim.opt.foldlevel = 1
    else
      vim.opt.foldlevel = 99
    end
  end,
})
