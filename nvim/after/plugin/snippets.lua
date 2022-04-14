local ls = require('luasnip')
local types = require('luasnip.util.types')

ls.config.set_config {
  history = true,
  updateevents = "TextChanged,TextChangedI",
  -- enable_autosnippets = true,
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = {{ " <- Choice", "" }}
      }
    }
  }
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
vim.keymap.set("n", "<leader><leader>ss", "<cmd>source ~/dotfiles/nvim/after/plugin/snippets.lua<CR>")
-- Edit snippets
vim.keymap.set("n", "<leader><leader>se", ":lua require('luasnip.loaders.from_lua').edit_snippet_files()<CR>")

require('luasnip.loaders.from_lua').load({
  paths = "~/.config/nvim/luasnip"
})

-- If we are in a TS file, make all JS snippets available too.
ls.filetype_extend("typescript", {"javascript"})
-- If we are in a Svelte file, enable JS snippets
ls.filetype_extend("svelte", {"javascript"})
