local Path = require("plenary.path")
require("jack.plugins.globals")

local M = {}

local function zero_pad(x)
  return x > 9 and x or "0" .. tostring(x)
end

local function current_date_for_filename()
  local d = os.date("*t")

  local month = zero_pad(d.month)
  local day = zero_pad(d.day)

  return table.concat({
    d.year,
    month,
    day,
  }, "-")
end

local function git_status_clean(pwd)
  local result = vim
    .system({
      "git",
      "status",
      "--porcelain",
    }, {
      cwd = pwd,
    })
    ---@diagnostic disable-next-line: undefined-field
    :wait()
  return result.code == 0
end

local function open_notes_file(root_dir, file_name)
  local root_path = Path:new(root_dir)
  local full_path = root_path:joinpath(file_name)
  vim.cmd("vsplit " .. tostring(full_path))
end

local default_notes_dir = tostring(Path:new(os.getenv("HOME")):joinpath("git"):joinpath("notes"))

M._default_settings = {
  notes_dir = default_notes_dir,
}

M.setup = function(config)
  M._settings = vim.tbl_deep_extend("force", M._default_settings, config or {})
end

M.open_daily_notes = function()
  local file_name = Path:new(current_date_for_filename() .. ".md")
  open_notes_file(M._settings.notes_dir, file_name)
end

M.input_prompt = function(callback_func)
  local Input = require("nui.input")
  local event = require("nui.utils.autocmd").event

  local input = Input({
    relative = "editor",
    position = "50%",
    size = {
      width = 50,
    },
    border = {
      style = "single",
      text = {
        top = "Name of notes file",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
    prompt = "> ",
    default_value = "",
    on_submit = function(value)
      callback_func(value)
    end,
  })

  -- mount/open the component
  input:mount()

  -- unmount component when cursor leaves buffer
  input:on(event.BufLeave, function()
    input:unmount()
  end)
  input:map("n", "<Esc>", function()
    input:unmount()
  end, { noremap = true })

  -- Make q close the input.
  input:map("n", "q", function()
    input:unmount()
  end, { noremap = true })
end

M.open_note_by_name = function()
  M.input_prompt(function(input_name)
    local file_name = Path:new(input_name .. ".md")
    open_notes_file(M._settings.notes_dir, file_name)
  end)
end

M.list_daily_notes_fzf = function()
  require("fzf-lua").files({
    git_icons = false,
    file_icons = false,
    cwd = M._settings.notes_dir,
    no_header_i = true,
  })
end

M.search_daily_notes_fzf = function()
  require("fzf-lua").live_grep_native({
    cwd = M._settings.notes_dir,
    no_header_i = true,
  })
end

M.commit_notes = function()
  local needs_commit = git_status_clean(M._settings.notes_dir) == false

  if needs_commit then
    local day_text = current_date_for_filename()
    local d = os.date("*t")
    local time_text = table.concat({
      zero_pad(d.hour),
      zero_pad(d.min),
      zero_pad(d.sec),
    }, ":")
    local commit_time = day_text .. " @ " .. time_text
    vim
      .system({ "git", "add", "*.md" }, {
        text = true,
        cwd = M._settings.notes_dir,
      })
      ---@diagnostic disable-next-line: undefined-field
      :wait()

    vim
      .system({ "git", "commit", "-m", "notes-update-" .. commit_time }, {
        text = true,
        cwd = M._settings.notes_dir,
      })
      ---@diagnostic disable-next-line: undefined-field
      :wait()
  end
  vim.system({ "git", "push" }, {
    text = true,
    cwd = M._settings.notes_dir,
  }, function(res)
    print("notes pushed (status code: " .. res.code .. ")")
  end)
  ---@diagnostic disable-next-line: undefined-field
end

return M
