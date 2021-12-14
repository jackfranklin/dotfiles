local has_plugins = pcall(require, 'lualine')
if not has_plugins then
  return
end
require('lualine').setup({
  options = {
    theme = 'onelight',
    icons_enabled = false,
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
  },
  sections = {
    lualine_c = {{
      'filename',
      -- 0 = filename, 1 = relative path, 2 = absolute path
      path = 1,
    }},
    lualine_x = {'filetype',},
    lualine_y = {{
      'diagnostics',
      sources = {'nvim_diagnostic'},
    }},
  },
})
