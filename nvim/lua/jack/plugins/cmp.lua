local cmp = require("cmp")

local cmp_mappings = {
  ["<C-d>"] = cmp.mapping.scroll_docs(-4),
  ["<C-u>"] = cmp.mapping.scroll_docs(4),
  ["<C-c>"] = cmp.mapping.close(),
  ["<C-space>"] = cmp.mapping.complete(),
  ["<CR>"] = cmp.mapping.confirm({ select = true }),
  ["<C-p>"] = cmp.mapping.select_prev_item(),
  ["<C-n>"] = cmp.mapping.select_next_item(),
}

cmp.setup({
  completion = {
    completeopt = "menu,menuone,noinsert",
  },
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  window = {
    documentation = cmp.config.window.bordered({
      scrolloff = 2,
      side_padding = 2,
      max_height = 10,
    }),
  },
  mapping = cmp_mappings,
  performance = {
    max_view_entries = 20,
  },
  sources = {
    { name = "luasnip", max_item_count = 2, priority = 10 },
    { name = "nvim_lsp", max_item_count = 10, priority = 5 },
    { name = "nvim_lua", max_item_count = 4, keyword_length = 2, priority = 2 },
    { name = "path", keyword_length = 3, max_item_count = 5, priority = 2 },
    { name = "buffer", max_item_count = 4, keyword_length = 5, priority = 1 },
  },
})
