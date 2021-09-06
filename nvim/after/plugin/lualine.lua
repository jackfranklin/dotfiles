require('lualine').setup({
  options = {
    theme = 'onelight',
    icons_enabled = false,
  },
  sections = {
    lualine_x = {
      'filetype',
    },
    lualine_y = {{
      'diagnostics',
      sources = {'nvim_lsp'},
    }},
  },
})
