local tree = require("nvim-treesitter")

tree.setup()

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then
      return
    end
    local installed = require("nvim-treesitter.config").get_installed()
    if vim.tbl_contains(installed, lang) then
      vim.treesitter.start()
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    else
      vim.notify("No treesitter parser installed for: " .. lang, vim.log.levels.WARN)
    end
  end,
})

local ensure_installed_langs = {
  "c",
  "comment",
  "cpp",
  "css",
  "csv",
  "elm",
  "fish",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "html",
  "javascript",
  "json",
  "json5",
  -- "jsonc", -- not currently supported in nvim-treesitter
  "lua",
  "luadoc",
  "make",
  "markdown",
  "markdown_inline",
  "ninja",
  "python",
  "ruby",
  "rust",
  "scss",
  "sql",
  "ssh_config",
  "svelte",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}
local alreadyInstalled = require("nvim-treesitter.config").get_installed()
local parsersToInstall = vim
  .iter(ensure_installed_langs)
  :filter(function(parser)
    return not vim.tbl_contains(alreadyInstalled, parser)
  end)
  :totable()
require("nvim-treesitter").install(parsersToInstall)

require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
    include_surrounding_whitespace = true,
  },
  move = {
    set_jumps = true,
  },
})

local select = require("nvim-treesitter-textobjects.select")
local textobj = function(query)
  return function()
    select.select_textobject(query, "textobjects")
  end
end

vim.keymap.set({ "x", "o" }, "aa", textobj("@parameter.outer"), { desc = "Select outer part of a parameter/argument" })
vim.keymap.set({ "x", "o" }, "ia", textobj("@parameter.inner"), { desc = "Select inner part of a parameter/argument" })
vim.keymap.set({ "x", "o" }, "ai", textobj("@conditional.outer"), { desc = "Select outer part of a conditional" })
vim.keymap.set({ "x", "o" }, "ii", textobj("@conditional.inner"), { desc = "Select inner part of a conditional" })
vim.keymap.set({ "x", "o" }, "al", textobj("@loop.outer"), { desc = "Select outer part of a loop" })
vim.keymap.set({ "x", "o" }, "il", textobj("@loop.inner"), { desc = "Select inner part of a loop" })
vim.keymap.set(
  { "x", "o" },
  "af",
  textobj("@function.outer"),
  { desc = "Select outer part of a method/function definition" }
)
vim.keymap.set(
  { "x", "o" },
  "if",
  textobj("@function.inner"),
  { desc = "Select inner part of a method/function definition" }
)
vim.keymap.set({ "x", "o" }, "ac", textobj("@class.outer"), { desc = "Select outer part of a class" })
vim.keymap.set({ "x", "o" }, "ic", textobj("@class.inner"), { desc = "Select inner part of a class" })

local move = require("nvim-treesitter-textobjects.move")
local goto_next_start = function(query)
  return function()
    move.goto_next_start(query, "textobjects")
  end
end
local goto_prev_start = function(query)
  return function()
    move.goto_previous_start(query, "textobjects")
  end
end

vim.keymap.set({ "n", "x", "o" }, "gaf", goto_next_start("@call.outer"), { desc = "Next function call start" })
vim.keymap.set(
  { "n", "x", "o" },
  "gam",
  goto_next_start("@function.outer"),
  { desc = "Next method/function def start" }
)
vim.keymap.set({ "n", "x", "o" }, "gac", goto_next_start("@class.outer"), { desc = "Next class start" })
vim.keymap.set({ "n", "x", "o" }, "gai", goto_next_start("@conditional.outer"), { desc = "Next conditional start" })
vim.keymap.set({ "n", "x", "o" }, "gal", goto_next_start("@loop.outer"), { desc = "Next loop start" })

vim.keymap.set({ "n", "x", "o" }, "gaF", goto_prev_start("@call.outer"), { desc = "Prev function call start" })
vim.keymap.set(
  { "n", "x", "o" },
  "gaM",
  goto_prev_start("@function.outer"),
  { desc = "Prev method/function def start" }
)
vim.keymap.set({ "n", "x", "o" }, "gaC", goto_prev_start("@class.outer"), { desc = "Prev class start" })
vim.keymap.set({ "n", "x", "o" }, "gaI", goto_prev_start("@conditional.outer"), { desc = "Prev conditional start" })
vim.keymap.set({ "n", "x", "o" }, "gaL", goto_prev_start("@loop.outer"), { desc = "Prev loop start" })

require("treesitter-context").setup({
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 1, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to show for a single context
  trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
})
vim.keymap.set("n", "gx", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true, desc = "[g]o to the conte[x]t" })
