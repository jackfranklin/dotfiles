local M = {}

local defaults = {
  flags = { "--vimgrep", "--smart-case", "--fixed-strings" },
  highlight_matches = true,
}

local config = {}
local active_search = nil
local history = {}

local function parse_args(args_string)
  local pattern = nil
  local flags = {}
  local dir = nil

  -- Extract quoted string as pattern (single or double quotes)
  local remaining = args_string
  local quote_pattern = remaining:match('["\']')
  if quote_pattern then
    local q = quote_pattern
    local s, e = remaining:find(q .. ".-" .. q)
    if s and e then
      pattern = remaining:sub(s + 1, e - 1)
      remaining = remaining:sub(1, s - 1) .. remaining:sub(e + 1)
    end
  end

  -- Parse remaining tokens
  for token in remaining:gmatch("%S+") do
    if token:match("^%-") then
      table.insert(flags, token)
    elseif pattern == nil then
      pattern = token
    else
      dir = token
    end
  end

  return pattern, flags, dir
end

local function push_history(pattern)
  for i, p in ipairs(history) do
    if p == pattern then
      table.remove(history, i)
      break
    end
  end
  table.insert(history, 1, pattern)
  if #history > 10 then
    table.remove(history) -- no index = removes last element (oldest)
  end
end

local function run_rg(pattern, opts)
  opts = opts or {}
  local extra_flags = opts.flags or {}
  local dir = opts.dir or ""

  if not pattern or pattern == "" then
    vim.notify("Rg: no search pattern provided", vim.log.levels.WARN)
    return
  end
  push_history(pattern)

  local cmd = { "rg" }
  for _, f in ipairs(config.flags) do
    table.insert(cmd, f)
  end
  for _, f in ipairs(extra_flags) do
    table.insert(cmd, f)
  end
  table.insert(cmd, "--")
  table.insert(cmd, pattern)
  if dir ~= "" then
    table.insert(cmd, dir)
  end

  if active_search then
    active_search:kill("sigterm")
    active_search = nil
  end

  active_search = vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      active_search = nil
      if result.stderr and result.stderr ~= "" then
        vim.notify("Rg: " .. result.stderr, vim.log.levels.WARN)
      end

      if not result.stdout or result.stdout == "" then
        vim.notify("Rg: no results for '" .. pattern .. "'", vim.log.levels.INFO)
        return
      end

      local lines = {}
      for line in result.stdout:gmatch("[^\n]+") do
        table.insert(lines, line)
      end

      vim.fn.setqflist({}, " ", {
        title = "Rg: " .. pattern,
        lines = lines,
        efm = "%f:%l:%c:%m",
      })
      if config.highlight_matches then
        vim.fn.setreg("/", pattern)
        vim.opt.hlsearch = true
      end
      vim.cmd("copen")
    end)
  end)
end

function M.search(pattern, opts)
  run_rg(pattern, opts)
end

function M.prompt()
  vim.ui.input({ prompt = "Rg: " }, function(input)
    if input and input ~= "" then
      run_rg(input)
    end
  end)
end

function M.history_select()
  if #history == 0 then
    vim.notify("Rg: no search history", vim.log.levels.INFO)
    return
  end
  vim.ui.select(history, { prompt = "Rg history:" }, function(choice)
    if choice then
      run_rg(choice)
    end
  end)
end

function M.word()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    vim.notify("Rg: no word under cursor", vim.log.levels.WARN)
    return
  end
  run_rg(word, { flags = { "--word-regexp" } })
end

function M.setup(user_config)
  config = vim.tbl_deep_extend("force", defaults, user_config or {})

  vim.api.nvim_create_user_command("Rg", function(cmd_opts)
    local pattern, flags, dir = parse_args(cmd_opts.args)
    M.search(pattern, { flags = flags, dir = dir or "" })
  end, { nargs = "+", desc = "Search with ripgrep" })

  vim.api.nvim_create_user_command("RgPrompt", function()
    M.prompt()
  end, { desc = "Search with ripgrep (interactive prompt)" })

  vim.api.nvim_create_user_command("RgWord", function()
    M.word()
  end, { desc = "Search word under cursor with ripgrep" })

  vim.api.nvim_create_user_command("RgHistory", function()
    M.history_select()
  end, { desc = "Pick a previous ripgrep search from history" })
end

return M
