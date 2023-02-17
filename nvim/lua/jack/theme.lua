vim.g.catppuccin_flavour = "latte"
vim.api.nvim_exec([[set background=light]], { output = "false" })
require("catppuccin").setup({
  styles = {
    -- Prevent conditionals from being italic
    conditionals = {},
  },
  custom_highlights = function(colors)
    return {
      ["@tag.attribute.tsx"] = { style = { "italic" } },
      ["@text.todo"] = { fg = colors.base, bg = colors.yellow, style = { "bold" } },
      TabLineSel = {
        bg = colors.green,
        fg = colors.base,
      },
      Folded = {
        bg = colors.mantle,
        fg = colors.text,
      },
    }
  end,
})
-- Generate a set of colors to look at:
-- local latte = require("catppuccin.palettes").get_palette("latte")
-- local colors = {
--   base = "#EFF1F5",
--   blue = "#1e66f5",
--   crust = "#DCE0E8",
--   flamingo = "#DD7878",
--   green = "#40A02B",
--   lavender = "#7287FD",
--   mantle = "#E6E9EF",
--   maroon = "#E64553",
--   mauve = "#8839EF",
--   overlay0 = "#9CA0B0",
--   overlay1 = "#8C8FA1",
--   overlay2 = "#7C7F93",
--   peach = "#FE640B",
--   pink = "#ea76cb",
--   red = "#D20F39",
--   rosewater = "#dc8a78",
--   sapphire = "#209FB5",
--   sky = "#04A5E5",
--   subtext0 = "#6C6F85",
--   subtext1 = "#5C5F77",
--   surface0 = "#CCD0DA",
--   surface1 = "#BCC0CC",
--   surface2 = "#ACB0BE",
-- teal = "#179299",
--   text = "#4C4F69",
--   yellow = "#df8e1d",
-- }
-- print(vim.inspect(latte))
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
hi JackStatusBarNavic cterm=italic gui=italic guibg=#e6e9ef
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
