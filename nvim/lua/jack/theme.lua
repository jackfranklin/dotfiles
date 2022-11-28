vim.g.catppuccin_flavour = "latte"
require("catppuccin").setup({
  styles = {
    -- Prevent conditionals from being italic
    conditionals = {},
  },
})
vim.api.nvim_command("colorscheme catppuccin")
local theme = vim.api.nvim_cmd({ cmd = "colorscheme" }, { output = true })
vim.api.nvim_exec(
  [[
hi JackStatusBarDiagnosticError guifg=#e45649 guibg=#f0f0f0
hi JackStatusBarDiagnosticWarn guifg=#ca1243 guibg=#f0f0f0
hi JackStatusBarDiagnosticHint guifg=#8B0000 guibg=#f0f0f0
]],
  true
)
if theme == "catppuccin" then
  vim.api.nvim_exec(
    [[
hi NormalFloat guibg=none
hi JackStatusBarDiagnosticError guifg=#e45649 guibg=#e6e9ef
hi JackStatusBarDiagnosticWarn guifg=#ca1243 guibg=#e6e9ef
hi JackStatusBarDiagnosticHint guifg=#8B0000 guibg=#e6e9ef
hi Winbar guibg=#e6e9ef
]],
    true
  )
end
if theme == "onebuddy" then
  vim.api.nvim_exec(
    [[
" this is the same as IncSearch in the onebuddy color theme
highlight Search guifg=#fafafa guibg=#4078f2 guisp=none
highlight DiagnosticFloatingInfo guifg=#000000 guisp=none
highlight DiagnosticFloatingWarn guifg=#000000 guisp=none
highlight DiagnosticFloatingHint guifg=#000000 guisp=none
highlight DiagnosticUnderlineInfo cterm=underline guisp=black gui=underline
highlight DiagnosticUnderlineHint cterm=underline guisp=black gui=underline
highlight DiagnosticHint guifg=black
highlight DiagnosticInfo guifg=black
highlight DiagnosticWarn guifg=black
highlight TabLineSel guifg=white
hi StatusLine guifg=black guibg=#f0f0f0
hi JackStatusBarFugitive guifg=#494b53 guibg=#f0f0f0
hi JackStatusBarNavic guifg=#494b53 guibg=#d0d0d0
hi WinbarNC gui=none guifg=gray
hi JackStatusBarDiagnosticError guifg=#e45649 guibg=#f0f0f0
hi JackStatusBarDiagnosticWarn guifg=#ca1243 guibg=#f0f0f0
hi JackStatusBarDiagnosticHint guifg=#8B0000 guibg=#f0f0f0
hi NormalFloat guibg=none
  ]],
    { output = true }
  )
end
