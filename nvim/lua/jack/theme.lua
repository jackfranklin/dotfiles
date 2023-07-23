local catppuccin_flavour = "frappe"
vim.g.catppuccin_flavour = catppuccin_flavour

if catppuccin_flavour == "latte" then
  vim.api.nvim_exec([[set background=light]], { output = "false" })
elseif catppuccin_flavour == "frappe" then
  vim.api.nvim_exec([[set background=dark]], { output = "false" })
end

require("dark_flat").setup({
  themes = function(colors)
    return {
      ["@punctuation.bracket"] = { fg = colors.pink:darken(0.7) },
      ["@include.typescript"] = { fg = colors.white:darken(0.5), italic = true },

      MatchParen = { fg = colors.white },
      CursorLine = { bg = colors.vulcan:darken(0.5) },
      Normal = { bg = colors.none },
      WinBar = { bg = colors.black, fg = colors.light_gray, bold = true },
    }
  end,
})

require("catppuccin").setup({
  styles = {
    -- Prevent conditionals from being italic
    conditionals = {},
  },
  custom_highlights = function(colors)
    return {
      ["@tag.attribute.tsx"] = { style = { "italic" } },
      ["@keyword.coroutine"] = {
        fg = colors.mauve,
        style = { "italic" },
      },
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
  highlight_overrides = {
    frappe = function(frappe)
      return {
        WinBar = { bg = frappe.mantle, fg = frappe.green },
        WinBarFile = { bg = frappe.mantle, fg = frappe.green },
        WinBarPath = { bg = frappe.mantle, fg = frappe.text },
        JackStatusBarDiagnosticError = { bg = frappe.mantle, fg = frappe.red },
        JackStatusBarDiagnosticWarn = { bg = frappe.mantle, fg = frappe.pink },
        JackStatusBarDiagnosticHint = { bg = frappe.mantle, fg = frappe.yellow },
        JackStatusBarNavic = { style = { "italic" }, bg = frappe.mantle },
      }
    end,
  },
})
-- Generate a set of colors to look at:
-- local latte = require("catppuccin.palettes").get_palette("latte")
-- local frappe = require("catppuccin.palettes").get_palette("frappe")

vim.api.nvim_command("colorscheme dark_flat")
local theme = vim.api.nvim_cmd({ cmd = "colorscheme" }, { output = true })

if theme == "catppuccin" and catppuccin_flavour == "latte" then
  vim.api.nvim_exec(
    [[
hi NormalFloat guibg=none
hi JackStatusBarDiagnosticError guifg=#e45649 guibg=#e6e9ef
hi JackStatusBarDiagnosticWarn guifg=#ca1243 guibg=#e6e9ef
hi JackStatusBarDiagnosticHint guifg=#8B0000 guibg=#e6e9ef
    " Make the DiagnosticUnnecessary look like the one used for eslint errors too.
hi DiagnosticUnnecessary gui=underline,italic guisp=#d20f39 cterm=italic,underline guifg=#9ca0b0
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
if theme == "dark_flat" then
  vim.api.nvim_exec(
    [[
hi JackStatusBarDiagnosticError guifg=#d54e53 guibg=#1e2024
hi JackStatusBarDiagnosticWarn guifg=#d19a66 guibg=#1e2024
hi JackStatusBarDiagnosticHint guifg=#676e7b guibg=#1e2024
  ]],
    { output = true }
  )
end
