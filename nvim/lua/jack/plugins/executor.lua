local M = {}

local executor = require("executor")

M.setup = function(config)
  local preset_commands = {
    ["executor.nvim"] = {
      "make test",
    },
    ["routemaster"] = {
      { partial = true, cmd = 'make tests-with-glob GLOB="test/' },
      "npm run build-run-tests",
      "npm run build-run-tests-esbuild",
      "npm run typecheck",
      "npm run check-lint",
    },
  }
  local merged_preset_commands = vim.tbl_deep_extend("force", preset_commands, config.preset_commands or {})

  require("executor").setup({
    use_split = false,
    notifications = {
      task_started = false,
      task_completed = false,
    },
    popup = {
      height = vim.o.lines - 10,
    },
    preset_commands = merged_preset_commands,
    output_filter = function(command, lines)
      if config.output_filter then
        return config.output_filter(command, lines)
      else
        return lines
      end
    end,
    statusline = {
      prefix_text = "",
      icons = {
        failed = "F",
        passed = "P",
      },
    },
  })
  local normal_key = function(lhs, func, which_key_desc)
    local opts = { desc = "[e]xecutor " .. which_key_desc, noremap = true, silent = true }
    vim.keymap.set("n", lhs, func, opts)
  end

  normal_key("<leader>er", executor.commands.run, "[r]un")
  normal_key("<leader>ev", executor.commands.toggle_detail, "[v]iew detail")
  normal_key("<leader>es", executor.commands.set_command, "[s]et command")
  normal_key("<leader>ep", executor.commands.show_presets, "show [p]resets")
  normal_key("<leader>eh", executor.commands.show_history, "show [h]istory")
end

return M
