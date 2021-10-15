local has_plugins = pcall(require, 'nvim-autopairs');

if not has_plugins then
  return
end

require('nvim-autopairs').setup({})

require('nvim-autopairs.completion.cmp').setup({
  map_cr = true,
  map_complete = false, -- don't insert a bracket after auto completing a method name
  auto_select = true
})
