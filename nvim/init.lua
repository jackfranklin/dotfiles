local has_per_machine, per_machine = pcall(require, "jack.per_machine")

local machine_env = has_per_machine and per_machine.machine_name or "default"

require("jack.base-settings")
require("jack.load_plugins").load()
require("jack.theme").load_catppuccin_light({ env = machine_env })

require("jack.statusline")
require("jack.maps")
require("jack.folds")
require("jack.terminal").setup()

local lsp_attach = require("lsp_on_attach")
lsp_attach.bind_on_attach_auto_cmd()
lsp_attach.register_lsp_keymaps()

local rg = require("jack.rg")
rg.setup()
vim.keymap.set("n", "<leader>/", ":Rg<Space>", { desc = "Search with Rg" })
vim.keymap.set("n", "<leader>rg", rg.prompt, { desc = "Rg prompt" })
vim.keymap.set("n", "<leader>rw", rg.word, { desc = "Rg word under cursor" })

local format_on_save = require("jack.format-on-save")

local notes = require("jack.notes")

notes.setup()
vim.keymap.set("n", "<leader>nd", notes.open_daily_notes, { desc = "[n]ote [d]aily: open note file for current day" })
vim.keymap.set("n", "<leader>nn", notes.open_note_by_name, { desc = "[n]ote [n]ew: open note file by name" })
vim.keymap.set("n", "<leader>ng", notes.commit_notes, { desc = "[n]otes [g]it: update and push notes to repo" })
vim.keymap.set("n", "<leader>nl", notes.list_daily_notes_fzf, { desc = "[n]otes [l]ist: search for notes file" })
vim.keymap.set("n", "<leader>ns", notes.search_daily_notes_fzf, { desc = "[n]otes [s]earch: text search all notes" })
vim.keymap.set("n", "<leader>nr", notes.open_from_recent_notes, { desc = "[n]otes [r]ecent: list recent note files" })

format_on_save.create_autocmd()
