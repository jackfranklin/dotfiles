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
