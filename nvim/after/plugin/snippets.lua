local ls = require('luasnip')
local types = require('luasnip.util.types')

ls.config.set_config {
  history = true,

  -- updateevents = "TextChanged,TextChangedI",

  enable_autosnippets = true,
}

-- Expand current snippet or jump to next item within snippet.
vim.keymap.set({ "i", "s" }, "<c-k>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

-- Go back to the previous part of the snippet.
vim.keymap.set({ "i", "s" }, "<c-j>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

-- Use <c-l> to select from options
vim.keymap.set("i", "<c-l>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end, { silent = true })

-- Reload snippets.
vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/dotfiles/nvim/after/plugin/snippets.lua<CR>")

-- TODO: create folder for snippets following: https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#lua-snippets-loader
ls.add_snippets(nil, {
  all = {
    ls.parser.parse_snippet("testing", "hello world"),
  },
  lua = {
    ls.parser.parse_snippet("lf", "local $1 = function($2)\n  $0\nend"),
  }
})

-- If we are in a TS file, make all JS snippets available too.
ls.filetype_extend("typescript", {"javascript"})
