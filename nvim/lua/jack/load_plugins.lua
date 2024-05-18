local M = {}

local base_plugins = function()
  return {
    --
    -- THEME + COLOURS
    --
    {
      "rebelot/kanagawa.nvim",
      lazy = false,
      priority = 1000,
    },
    { "catppuccin/nvim", name = "catppuccin", priority = 1000, lazy = false },
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
    -- { "tpope/vim-commentary", event = { "BufReadPre" } },
    {
      "tpope/vim-fugitive",
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
    {
      "echasnovski/mini.diff",
      event = { "BufReadPre" },
      config = function()
        require("jack.plugins.mini-diff")
      end,
    },
    {
      "echasnovski/mini.indentscope",
      config = function()
        require("jack.plugins.mini-indent")
      end,
    },
    {
      "ojroques/vim-oscyank",
      cmd = "OSCYankVisual",
      keys = {
        { "<leader>yo", mode = "v" },
      },
      config = function()
        vim.keymap.set("v", "<leader>yo", "<Plug>OSCYankVisual", {
          desc = "[Y]ank [O]ut text to the system clipboard",
        })
      end,
    },
    {
      "mileszs/ack.vim",
      lazy = true,
      cmd = { "Ack" },
      keys = { { "<leader>/", desc = "Search with Ack!" } },
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
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
      end,
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
    },
    {
      "folke/neodev.nvim",
      lazy = false,
    },
    -- FUZZY FINDERS
    {
      "ibhagwan/fzf-lua",
      config = function()
        require("jack.plugins.fzf-lua").setup({})
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
      -- event = "BufReadPre",
      dependencies = {
        -- This plugin does not depend on this, but my
        -- config does.
        "nvim-lua/plenary.nvim",
      },
      config = function()
        require("jack.plugins.lsp")
      end,
    },
    {
      "rmagatti/goto-preview",
      keys = { "gp", mode = "n" },
      config = function()
        require("jack.plugins.gotopreview")
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
    }, --
    -- AUTO FORMATTING
    --
    -- {
    --   "stevearc/conform.nvim",
    --   config = function()
    --     require("jack.plugins.conform").setup({})
    --   end,
    --   event = "BufWritePre",
    -- },
    {
      "nvimtools/none-ls.nvim",
      dependencies = {
        "nvimtools/none-ls-extras.nvim",
      },
      config = function()
        require("jack.plugins.nonels").setup()
      end,
    },
  }
end

M.load = function(config)
  config = config or {}
  local extra_plugins = config.extra_plugins or {}
  local config_overrides = config.config_overrides or {}

  local final_plugins = {}
  for k, v in pairs(base_plugins()) do
    final_plugins[k] = v
    local plugin_name = v[1] or v.dir
    local override_config = config_overrides[plugin_name]
    if override_config then
      final_plugins[k].config = override_config
    end
  end
  for k, v in pairs(extra_plugins) do
    final_plugins[k] = v
  end

  require("jack.lazy").run_lazy(final_plugins)
end

return M
