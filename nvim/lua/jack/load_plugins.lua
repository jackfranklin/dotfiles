local M = {}

local base_plugins = {
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
    -- dir = "~/git/winbar.nvim",
    config = function()
      require("jack.plugins.winbar")
    end,
  },
  --
  -- TPOPE
  --
  { "tpope/vim-commentary", keys = { { "gc", mode = "n" }, { "gcc", mode = "v" } } },
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
    keys = { "<leader>/" },
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
    keys = { "<leader>er", "<leader>ep" },
    config = function()
      require("jack.plugins.executor").setup({})
    end,
  },
  --
  -- LSP, auto-complete and snippets
  --
  {
    "mattn/emmet-vim",
    keys = { { "<C-e>", mode = { "i", "v" } } },
    init = function()
      -- We use init here as the config for this plugin is
      -- setting two global variables which must be set
      -- before the plugin is loaded.
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
    event = "BufReadPre",
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
}

M.load = function(config)
  config = config or {}
  local extra_plugins = config.extra_plugins or {}
  local config_overrides = config.config_overrides or {}

  local final_plugins = {}
  for k, v in pairs(base_plugins) do
    final_plugins[k] = v
    local plugin_name = v[1]
    local override_config = config_overrides[plugin_name]
    if override_config then
      print("override found " .. plugin_name)
      final_plugins[k].config = override_config
    end
  end
  for k, v in pairs(extra_plugins) do
    final_plugins[k] = v
  end

  require("jack.lazy").run_lazy(final_plugins)
end

return M
