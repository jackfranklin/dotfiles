require("jack.base-settings")

require("jack.load_plugins").load()

require("jack.statusline")
require("jack.maps")
require("jack.folds")

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
