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

local function load_kanagawa(env)
  require("kanagawa").setup({
    undercurl = env ~= "wsl",
    dimInactive = true,
    overrides = function(colors)
      return {
        ["@comment.todo"] = { fg = colors.palette.lotusRed },
        Boolean = { bold = false },
        JackStatusBarDiagnosticError = { fg = colors.theme.diag.error, bg = colors.theme.ui.bg_m3 },
        JackStatusBarDiagnosticWarn = { fg = colors.theme.diag.warn, bg = colors.theme.ui.bg_m3 },
        JackStatusBarDiagnosticHint = { fg = colors.theme.diag.hint, bg = colors.theme.ui.bg_m3 },
        JackStatusBarDiagnosticInfo = { fg = colors.theme.diag.hint, bg = colors.theme.ui.bg_m3 },
        JackStatusBarNavic = { italic = true, bg = colors.theme.ui.bg_m3, fg = colors.theme.fg_dim },
        DiagnosticUnnecessary = { underline = true, fg = colors.theme.syn.comment },
        ExecutorFail = { fg = colors.theme.diag.error, bg = colors.theme.ui.bg_m3 },
        ExecutorPass = { fg = colors.theme.diag.ok, bg = colors.theme.ui.bg_m3 },
        ExecutorLastCommand = { fg = colors.theme.ui.fg_dim, bg = colors.theme.ui.bg_m3, italic = true },
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
      latte = function(latte)
        return {
          WinBar = { bg = latte.mantle, fg = latte.green },
          WinBarFile = { bg = latte.mantle, fg = latte.green },
          WinBarPath = { bg = latte.mantle, fg = latte.text },
          JackStatusBarDiagnosticError = { bg = latte.mantle, fg = latte.red },
          JackStatusBarDiagnosticWarn = { bg = latte.mantle, fg = latte.pink },
          JackStatusBarDiagnosticHint = { bg = latte.mantle, fg = latte.yellow },
          ExecutorFail = { bg = latte.mantle, fg = latte.red },
          ExecutorPass = { fg = latte.green, bg = latte.mantle },
          JackStatusBarNavic = { style = { "italic" }, bg = latte.mantle },
          NormalFloat = { bg = "none" },
        }
      end,
    },
  })
  -- Generate a set of colors to look at:
  -- local latte = require("catppuccin.palettes").get_palette("latte")
  -- local frappe = require("catppuccin.palettes").get_palette("frappe")
end

local M = {}

M.load_kanagawa = function(config)
  config = config or {}
  load_kanagawa(config.env)
  vim.api.nvim_command("colorscheme kanagawa")
end

M.load_catppuccin_light = function(config)
  load_catppuccin()
  vim.g.catppuccin_flavour = "latte"
  vim.api.nvim_exec2([[set background=light]], { output = false })
  vim.api.nvim_command("colorscheme catppuccin-latte")
end

return M
