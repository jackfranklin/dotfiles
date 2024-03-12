require("jack.base-settings")

require("jack.lazy").run_lazy({
  --
  -- THEME + COLOURS
  --
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("jack.theme")
    end,
  },
  {
    "jackfranklin/winbar.nvim",
    config = function()
      require("jack.plugins.winbar")
    end,
  },
  --
  -- TPOPE
  --
  { "tpope/vim-commentary", keys = "gc" },
  {
    "tpope/vim-fugitive",
    -- Cannot be lazy as we rely on it for the statusline.
    config = function()
      require("jack.plugins.fugitive")
    end,
  },
  "tpope/vim-sleuth",
  "tpope/vim-unimpaired",
  "thinca/vim-visualstar",
  --
  -- HANDY UTILS
  --
  {
    "echasnovski/mini.files",
    keys = "-",
    config = function()
      require("jack.plugins.mini-files")
    end,
  },
  { "ojroques/vim-oscyank", cmd = "OSCYankVisual" },
  {
    "mileszs/ack.vim",
    lazy = true,
    cmd = { "Ack" },
    config = function()
      require("jack.plugins.ack")
    end,
  },
  "farmergreg/vim-lastplace",
  {
    "kylechui/nvim-surround",
    config = function()
      require("jack.plugins.surround")
    end,
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("jack.plugins.autopairs")
    end,
  },
  --
  -- TERMINAL AND TASK RUNNERS
  --
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("jack.plugins.toggleterm")
    end,
  },
  {
    "ibhagwan/fzf-lua",
    keys = "<leader>t",
    config = function()
      require("jack.plugins.fzf-lua").setup({})
    end,
  },
  {
    dir = "~/git/executor.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("jack.plugins.executor").setup({})
    end,
  },
  --
  -- LSP, auto-complete and snippets
  --
  {
    "mattn/emmet-vim",
    keys = "<C-e>",
    config = function()
      require("jack.plugins.emmet-vim")
    end,
  },
  {
    "SmiteshP/nvim-navic",
  },
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    config = function()
      require("jack.plugins.snippets")
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require("jack.plugins.cmp")
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- This plugin does not depend on this, but my
      -- config does.
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("jack.plugins.lsp")
    end,
  },

  --
  -- TREESITTER
  --
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
    config = function()
      require("jack.plugins.treesitter")
    end,
  },

  --
  -- AUTO FORMATTING
  --
  {
    "stevearc/conform.nvim",
    config = function()
      require("jack.plugins.conform").setup({})
    end,
    event = "BufWritePre",
  },
})

require("jack.statusline")
require("jack.maps")
require("jack.folds")

-- require("jack.plugins.winbar")
-- require("jack.plugins.ack")
-- require("jack.plugins.autopairs")
-- require("jack.plugins.neorg-config").setup()
-- require("jack.plugins.conform").setup({})
-- require("jack.plugins.executor").setup({})
-- require("jack.plugins.emmet-vim")
-- require("jack.plugins.gitsigns")
-- require("jack.plugins.fterm").setup({})
-- require("jack.plugins.fugitive")
-- require("jack.plugins.fzf-lua").setup({})
-- require("jack.plugins.lsp")
-- require("jack.plugins.toggleterm")
-- require("jack.plugins.neoterm")
-- require("jack.plugins.snippets")
-- require("jack.plugins.statusline")
-- require("jack.plugins.surround")
-- require("jack.plugins.treesitter")
-- require("jack.plugins.mini-files")
