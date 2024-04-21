local M = {}

M.custom_ui_input = function(opts, callback_func)
  local width = math.floor(vim.o.columns * 4 / 5)

  local event = require("nui.utils.autocmd").event
  local Input = require("nui.input")
  local input_component = Input({
    relative = "editor",
    position = {
      row = "100%",
      col = 0.5,
    },
    size = {
      width = width,
    },
    border = {
      style = "rounded",
      padding = { top = 1, bottom = 1, left = 2, right = 2 },
      text = {
        top = opts.prompt or "Input:",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
  }, {
    prompt = "> ",
    default_value = opts.default or "",
    on_submit = function(value)
      callback_func(value)
    end,
    on_close = function()
      -- Nothing to do here.
    end,
  })
  -- Make <ESC> close the input
  input_component:map("n", "<Esc>", function()
    input_component:unmount()
  end, { noremap = true })
  -- Make q close the input.
  input_component:map("n", "q", function()
    input_component:unmount()
  end, { noremap = true })
  input_component:mount()
  input_component:on(event.BufLeave, function()
    input_component:unmount()
  end)
end
return M
