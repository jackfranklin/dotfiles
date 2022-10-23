local navic = require('nvim-navic')
navic.setup({
  icons = {
    File          = "",
    Module        = "",
    Namespace     = "",
    Package       = "",
    Class         = "[C] ",
    Method        = "[M] ",
    Property      = "[P] ",
    Field         = "[F] ",
    Constructor   = "",
    Enum          = "[E] ",
    Interface     = "[I] ",
    Function      = "[F] ",
    Variable      = "",
    Constant      = "",
    String        = "",
    Number        = "",
    Boolean       = "",
    Array         = "",
    Object        = "",
    Key           = "",
    Null          = "",
    EnumMember    = "",
    Struct        = "",
    Event         = "",
    Operator      = "",
    TypeParameter = "",
  },
})
vim.o.laststatus = 3
local get_diagnostics = function()
  -- 0 = current buffer
  local diags_for_buffer = vim.diagnostic.get(0)
  if table.getn(diags_for_buffer) == 0 then
    return nil
  end
  local count = { 0, 0, 0, 0 }
  for _, diagnostic in pairs(diags_for_buffer) do
    count[diagnostic.severity] = count[diagnostic.severity] + 1
 end
  local error = count[vim.diagnostic.severity.ERROR]
  local warning = count[vim.diagnostic.severity.WARN]
  local info = count[vim.diagnostic.severity.INFO]
  local hint = count[vim.diagnostic.severity.HINT]
  return {
    error = error,
    warning = warning,
    -- for my purposes I'm happy for these to be considered the same
    hint = info + hint,
  }
end
function LSPCount(key, letter)
  local diags = get_diagnostics()
  if diags == nil or diags[key] < 1 then
    return ''
  end
  local str = string.format("%s:%i ", letter, diags[key])
  return str
end
local diagnostic_status_line = [[%#JackStatusBarDiagnosticError#%{v:lua.LSPCount('error', 'E')}%*%#JackStatusBarDiagnosticWarn#%{v:lua.LSPCount('warning', 'W')}%*%#JackStatusBarDiagnosticHint#%{v:lua.LSPCount('hint', 'H')}%*]]
function StatusBarNavic()
  return navic.get_location()
end
local status_line_parts = {
  "%f",
  " ",
  diagnostic_status_line,
  "%=", -- this pushes what's after it to the RHS
  "%#JackStatusBarNavic#%{v:lua.StatusBarNavic()}%*",
  " ", -- bit of padding after the navigation
  "%#JackStatusBarFugitive#%{FugitiveStatusline()}%* ",
}
vim.o.statusline = table.concat(status_line_parts, "")