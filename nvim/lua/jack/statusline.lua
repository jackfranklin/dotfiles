local navic = require("nvim-navic")
local executor = require("executor")
navic.setup({
  icons = {
    File = "",
    Module = "",
    Namespace = "",
    Package = "",
    Class = "",
    Method = "",
    Property = "",
    Field = "",
    Constructor = "",
    Enum = "",
    Interface = "",
    Function = "",
    Variable = "",
    Constant = "",
    String = "",
    Number = "",
    Boolean = "",
    Array = "",
    Object = "",
    Key = "",
    Null = "",
    EnumMember = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
  },
  depth_limit = 3,
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
    return ""
  end
  local str = string.format("%s:%i ", letter, diags[key])
  return str
end

local diagnostic_status_line =
  [[%#JackStatusBarDiagnosticError#%{v:lua.LSPCount('error', 'E')}%*%#JackStatusBarDiagnosticWarn#%{v:lua.LSPCount('warning', 'W')}%*%#JackStatusBarDiagnosticHint#%{v:lua.LSPCount('hint', 'H')}%*]]

function StatusBarNavic()
  local text = navic.get_location()
  if text == "" then
    return ""
  end
  local without_callbacks = text:gsub(" callback", "")
  if string.len(without_callbacks) >= 90 then
    without_callbacks = "…" .. without_callbacks:sub(-85)
  end
  return without_callbacks
end

function StatusBarExecutor()
  local text = executor.statusline()
  if text == "" then
    return ""
  else
    -- Put another empty space on to split it from the next part
    return text .. " "
  end
end

local function executor_text(inner_text)
  -- Purposeful end space to pad out status bar items
  return "[" .. inner_text .. "] "
end

function ExecutorPassOutput()
  local status = executor.current_status()
  if status == "PASSED" then
    return executor_text("P")
  end
  return ""
end

function ExecutorFailOutput()
  local status = executor.current_status()
  if status == "FAILED" then
    return executor_text("F")
  end
  return ""
end

function ExecutorInProgressOutput()
  local status = executor.current_status()
  if status == "IN_PROGRESS" then
    return executor_text("…")
  end
  return ""
end

local executor_status = table.concat({
  "%#ExecutorPass#",
  "%{v:lua.ExecutorPassOutput()}",
  "%#Normal#",
  "%#ExecutorFail#",
  "%{v:lua.ExecutorFailOutput()}",
  "%#Normal#",
  "%#ExecutorInProgress#",
  "%{v:lua.ExecutorInProgressOutput()}",
  "%#Normal#",
}, "")

local status_line_parts = {
  executor_status,
  diagnostic_status_line,
  "%=", -- this pushes what's after it to the RHS
  "%#JackStatusBarNavic#%{v:lua.StatusBarNavic()}%*",
  " ", -- Padding between navic + fugitive
  "%#JackStatusBarFugitive#%{FugitiveStatusline()}%*",
}

vim.o.statusline = table.concat(status_line_parts, "")
