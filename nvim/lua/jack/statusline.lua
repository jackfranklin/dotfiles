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

local navicLimit = math.floor(vim.o.columns / 3)
function StatusBarNavic()
  local text = navic.get_location()
  if text == "" then
    return ""
  end
  local without_callbacks = text:gsub(" callback", "")
  if string.len(without_callbacks) >= navicLimit then
    without_callbacks = "…" .. without_callbacks:sub((navicLimit - 5) * -1)
  end
  return without_callbacks
end

local function is_outputting_executor_last_cmd()
  local data = executor.last_command()
  return data.one_off and data.cmd ~= nil
end

local function executor_text(inner_text)
  local suffix = ""
  if is_outputting_executor_last_cmd() == false then
    suffix = " "
  end
  return "[" .. inner_text .. "]" .. suffix
end

local codecompanion_is_processing = false

local function setup_code_companion_status()
  local success, cc = pcall(require, "codecompanion")
  if not success then
    return
  end

  local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionRequest*",
    group = group,
    callback = function(request)
      if request.match == "CodeCompanionRequestStarted" then
        codecompanion_is_processing = true
      elseif request.match == "CodeCompanionRequestFinished" then
        codecompanion_is_processing = false
      end
      vim.api.nvim_exec2("let &stl=&stl", { output = false }) --redraw status line
    end,
  })
end

setup_code_companion_status()

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

function ExecutorLastCommandOutput()
  if is_outputting_executor_last_cmd() == false then
    return ""
  end
  local data = executor.last_command()
  if data.one_off and data.cmd ~= nil then
    -- Purposeful start space to push it away from the [P] and end space to
    -- push the stuff to the right away
    -- (not sure why but it needs two spaces to look right!)
    return "  (" .. data.cmd .. ") "
  end

  return ""
end

function CodeCompanionStatus()
  if codecompanion_is_processing == false then
    return ""
  end

  -- prefix space because it goes on the far RHS
  return " [CC…]"
end

local executor_status = table.concat({
  "%#ExecutorPass#",
  "%{v:lua.ExecutorPassOutput()}",
  "%*",
  "%#ExecutorFail#",
  "%{v:lua.ExecutorFailOutput()}",
  "%*",
  "%#ExecutorInProgress#",
  "%{v:lua.ExecutorInProgressOutput()}",
  "%*",
  "%#ExecutorLastCommand#",
  "%{v:lua.ExecutorLastCommandOutput()}",
  "%*",
}, "")

local status_line_parts = {
  executor_status,
  diagnostic_status_line,
  "%=", -- this pushes what's after it to the RHS
  "%#JackStatusBarNavic#%{v:lua.StatusBarNavic()}%*",
  " ", -- Padding between navic + fugitive
  "%#JackStatusBarFugitive#%{FugitiveStatusline()}%*",
  "%#JackStatusBarCodeCompanion#%{v:lua.CodeCompanionStatus()}%*",
}

vim.o.statusline = table.concat(status_line_parts, "")
