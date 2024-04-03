local cmp = require("cmp")
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
      scrollbar = false,
    }),
  },
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-l>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<C-y>"] = cmp.mapping(
      cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      }),
      { "i", "c" }
    ),
    ["<C-n>"] = {
      i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    },
    ["<C-p>"] = {
      i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    },
  },
  performance = {
    max_view_entries = 20,
  },
  sources = {
    { name = "nvim_lsp", max_item_count = 10, priority = 5 },
    { name = "luasnip", max_item_count = 5, priority = 4 },
    { name = "nvim_lsp_signature_help" },

    { name = "nvim_lua", max_item_count = 4, keyword_length = 2, priority = 4 },
    { name = "path", keyword_length = 3, max_item_count = 10, priority = 3 },
    { name = "buffer", max_item_count = 10, keyword_length = 5, priority = 1 },
  },
})
