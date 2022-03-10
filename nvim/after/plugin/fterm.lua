-- require('toggleterm').setup{
--   close_on_exit = true
-- }

require('FTerm').setup({
  -- cmd = '',
  dimensions = {
    width = 0.4,
    height = 0.8,
    row = vim.o.lines - vim.o.cmdheight - 1,
    col = vim.o.columns,
  },
  anchor = 'SE',
  border = 'double',
})
