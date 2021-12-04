local has_plugins = pcall(require, 'nvim-autopairs');

if not has_plugins then
  return
end

require('nvim-autopairs').setup({})
