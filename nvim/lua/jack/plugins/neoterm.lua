vim.g.neoterm_size = tostring(0.3 * vim.o.columns)
vim.g.neoterm_default_mod = "botright vertical"

vim.api.nvim_exec(
  [[
autocmd BufEnter * if &filetype == 'neoterm' | :startinsert | endif
]],
  false
)

vim.api.nvim_set_keymap("n", "<leader>pe", ":TaskThenExit ", {})
vim.api.nvim_set_keymap("n", "<leader>pp", ":TaskPersist ", {})
vim.api.nvim_set_keymap("n", "<leader>pt", ":1Ttoggle<CR><ESC>", {})
vim.api.nvim_set_keymap("n", "<leader>et", ":TaskPersist<CR>", {})

local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local stored_task_command = nil

local trigger_set_command_input = function(callback_fn)
  local input_component = Input({
    position = "50%",
    size = {
      width = 50,
    },
    border = {
      style = "single",
      text = {
        top = "Commmand to run:",
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
      stored_task_command = value
      callback_fn()
    end,
  })

  input_component:mount()
  input_component:on(event.BufLeave, function()
    input_component:unmount()
  end)
end

vim.api.nvim_create_user_command("SetTaskCommand", function()
  trigger_set_command_input(function()
    -- Don't need to do anything here beyond set it
  end)
end, {})

vim.api.nvim_create_user_command("TaskThenExit", function(input)
  local cmd = input.args
  vim.api.nvim_command(":Tnew")
  vim.api.nvim_command(":T " .. cmd .. " && exit")
end, { bang = true, nargs = "*" })

vim.api.nvim_create_user_command("TaskPersist", function(input)
  local execute = function(cmd)
    vim.api.nvim_command(":1Tclear")
    vim.api.nvim_command(":1T clear && " .. cmd)
  end

  local one_off_command = input.args

  if one_off_command and string.len(one_off_command) > 0 then
    execute(one_off_command)
  elseif stored_task_command == nil then
    trigger_set_command_input(function()
      execute(stored_task_command)
    end)
  else
    execute(stored_task_command)
  end
end, { nargs = "*" })
