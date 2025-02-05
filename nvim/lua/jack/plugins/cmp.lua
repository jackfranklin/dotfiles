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
    }),
  },
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-u>"] = cmp.mapping.scroll_docs(4),
    ["<C-c>"] = cmp.mapping.close(),
    -- ["<C-y>"] = cmp.mapping(
    --   cmp.mapping.confirm({
    --     behavior = cmp.ConfirmBehavior.Insert,
    --     select = true,
    --   }),
    --   { "i", "c" }
    -- ),
    -- ["<C-n>"] = {
    --   i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    -- },
    -- ["<C-p>"] = {
    --   i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    -- },
    -- Trialling new settings
    ["<C-y>"] = cmp.mapping.complete(), -- force the autocomplete popup
    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- select suggestion
    ["<C-p>"] = cmp.mapping.select_prev_item(), -- previous suggestion
    ["<C-n>"] = cmp.mapping.select_next_item(), -- next suggestion
    ["<C-m>"] = require("minuet").make_cmp_map(),
  },
  performance = {
    max_view_entries = 20,
  },
  sources = {
    -- { name = "codeium", max_item_count = 3, priority = 6, keyword_length = 4 },
    -- { name = "minuet" },
    { name = "luasnip", max_item_count = 2, priority = 10 },
    { name = "nvim_lsp", max_item_count = 6, priority = 5 },
    { name = "nvim_lua", max_item_count = 4, keyword_length = 2, priority = 2 },
    { name = "path", keyword_length = 3, max_item_count = 5, priority = 2 },
    { name = "buffer", max_item_count = 4, keyword_length = 5, priority = 1 },
  },
})
