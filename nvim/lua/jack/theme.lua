local catppuccin_flavour = "frappe"
vim.g.catppuccin_flavour = catppuccin_flavour

if catppuccin_flavour == "latte" then
  vim.api.nvim_exec([[set background=light]], false)
elseif catppuccin_flavour == "frappe" then
  vim.api.nvim_exec([[set background=dark]], false)
end

local function load_dark_flat()
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
end

local function load_kanagawa()
  require("kanagawa").setup({
    undercurl = false, -- TODO: find out how to make this true for Mac only.
    dimInactive = true,
    overrides = function(colors)
      return {
        ["@comment.todo"] = { fg = colors.palette.lotusRed },
        JackStatusBarDiagnosticError = { fg = colors.theme.diag.error, bg = colors.theme.ui.bg_m3 },
        JackStatusBarDiagnosticWarn = { fg = colors.theme.diag.warn, bg = colors.theme.ui.bg_m3 },
        JackStatusBarDiagnosticHint = { fg = colors.theme.diag.hint, bg = colors.theme.ui.bg_m3 },
        JackStatusBarDiagnosticInfo = { fg = colors.theme.diag.info, bg = colors.theme.ui.bg_m3 },
        JackStatusBarNavic = { italic = true, bg = colors.theme.ui.bg_m3, fg = colors.theme.fg_dim },
        DiagnosticUnnecessary = { underline = true, fg = colors.theme.syn.comment },
        Folded = {
          italic = true,
          bg = colors.theme.ui.bg_m3,
          fg = colors.theme.fg,
        },
      }
    end,
  })
end

local function load_catppuccin()
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
end

local function load_tokyonight()
  require("tokyonight").setup({
    on_highlights = function(hl, colors)
      hl.JackStatusBarDiagnosticError = { fg = colors.red, bg = colors.bg_statusline }
      hl.JackStatusBarDiagnosticWarn = { fg = colors.orange, bg = colors.bg_statusline }
      hl.JackStatusBarDiagnosticHint = { fg = colors.fg, bg = colors.bg_statusline }
      hl.JackStatusBarNavic = {
        style = {
          italic = true,
        },
        bg = colors.bg_statusline,
        fg = colors.teal,
      }

      hl.DiagnosticUnderlineError = {
        style = {
          underline = true,
        },
      }
      hl.DiagnosticUnderlineWarn = {
        style = {
          underline = true,
        },
      }
      hl.DiagnosticUnderlineHint = {
        style = {
          underline = true,
        },
      }
      hl.DiagnosticUnderlineInfo = {
        style = {
          underline = true,
        },
      }
    end,
  })
end

load_kanagawa()
vim.api.nvim_command("colorscheme kanagawa")
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

if theme == "dark_flat" then
  vim.api.nvim_exec(
    [[
hi JackStatusBarDiagnosticError guifg=#d54e53 guibg=#1e2024
hi JackStatusBarDiagnosticWarn guifg=#d19a66 guibg=#1e2024
hi JackStatusBarDiagnosticHint guifg=#676e7b guibg=#1e2024
  ]],
    true
  )
end
