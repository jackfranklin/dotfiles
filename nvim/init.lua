local has_per_machine, per_machine = pcall(require, "jack.per_machine")

local machine_env = has_per_machine and per_machine.machine_name or "default"

require("jack.base-settings")
require("jack.load_plugins").load()
require("jack.theme").load_kanagawa({ env = machine_env })

require("jack.statusline")
require("jack.maps")
require("jack.folds")

local format_on_save = require("jack.format-on-save")

local custom_input = require("jack.custom-input")
vim.ui.input = custom_input.custom_ui_input

local notes = require("jack.notes")

notes.setup()
vim.keymap.set("n", "<leader>nd", notes.open_daily_notes, { desc = "[n]ote [d]aily: open note file for current day" })
vim.keymap.set("n", "<leader>nn", notes.open_note_by_name, { desc = "[n]ote [n]ew: open note file by name" })
vim.keymap.set("n", "<leader>ng", notes.commit_notes, { desc = "[n]otes [g]it: update and push notes to repo" })
vim.keymap.set("n", "<leader>nl", notes.list_daily_notes_fzf, { desc = "[n]otes [l]ist: search for notes file" })
vim.keymap.set("n", "<leader>ns", notes.search_daily_notes_fzf, { desc = "[n]otes [s]earch: text search all notes" })
vim.keymap.set("n", "<leader>nr", notes.open_from_recent_notes, { desc = "[n]otes [r]ecent: list recent note files" })

local alternate_files = require("jack.alternate-files")

local edit_file = function(file_path)
  vim.cmd(":e " .. file_path)
end

vim.keymap.set("n", "<leader>fa", function()
  local alternative_files = alternate_files.get_alternative_files({
    patterns = {
      [".test.ts"] = { ".ts" },
      [".ts"] = { ".test.ts", ".css" },
      [".css"] = { ".ts" },
    },
    filter = function(file_name)
      local utils = require("jack.utils")
      return utils.path_exists(file_name)
    end,
  })

  if #alternative_files == 0 then
    print("No alternative files found")
  elseif #alternative_files == 1 then
    edit_file(alternative_files[1])
  else
    vim.ui.select(alternative_files, {
      prompt = "[AltFile]: choose the file to edit",
    }, function(choice)
      if choice ~= nil then
        edit_file(choice)
      end
    end)
  end
end, { desc = "Jump to the [A]lternative file" })

format_on_save.create_autocmd()

-- Fix for flickering in Neovim when there are multiple parsers; this mostly impacts Markdown and its nested syntax highlighting in code blocks.
-- Context: https://github.com/neovim/neovim/issues/32660#comment-composer-heading
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.g._ts_force_sync_parsing = vim.bo.filetype == "markdown"
    -- print(
    --   "Setting _ts_force_sync_parsing to "
    --     .. tostring(vim.g._ts_force_sync_parsing)
    --     .. " for filetype: "
    --     .. vim.bo.filetype
    -- )
  end,
})
