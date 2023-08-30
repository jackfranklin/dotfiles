local M = {}

M.default = function()
  return {
    { "nvim-lua/popup.nvim", lazy = true },
    { "nvim-lua/plenary.nvim", lazy = true },
    { "MunifTanjim/nui.nvim", lazy = true },

    "mattn/emmet-vim",
    "tpope/vim-commentary",
    "tpope/vim-vinegar",
    { "tpope/vim-fugitive" },
    "tpope/vim-sleuth",
    "tpope/vim-eunuch",
    "tpope/vim-unimpaired",
    "thinca/vim-visualstar",
    { "mileszs/ack.vim", lazy = true, cmd = { "Ack" } },
    "farmergreg/vim-lastplace",
    "kylechui/nvim-surround",
    "windwp/nvim-autopairs",
    "akinsho/toggleterm.nvim",
    "neovim/nvim-lspconfig",

    -- COLOURS + THEMES
    "folke/lsp-colors.nvim",
    "tjdevries/colorbuddy.vim",
    -- "Th3Whit3Wolf/onebuddy",
    { "sekke276/dark_flat.nvim", priority = 1001 },
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

    -- Snippets and completion

    "L3MON4D3/LuaSnip",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/cmp-path",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lua",
    "saadparwaiz1/cmp_luasnip",

    "echasnovski/mini.files",
    "ojroques/vim-oscyank",
    "numToStr/FTerm.nvim",
    { "SmiteshP/nvim-navic", lazy = true },
    { "google/executor.nvim", lazy = true },
    "jackfranklin/winbar.nvim",
    "ibhagwan/fzf-lua",
    "jose-elias-alvarez/null-ls.nvim",
    "kassio/neoterm",
    { "rlane/pounce.nvim", lazy = true },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

    { "nvim-treesitter/nvim-treesitter-textobjects", dependencies = {
      "nvim-treesitter/nvim-treesitter",
    } },
  }

  -- use({
  --   after = "nvim-treesitter",
  --   requires = "nvim-treesitter/nvim-treesitter",
  -- })
end

M.load_plugins = function(use)
  use("wbthomason/packer.nvim")

  -- TODO: find out what depends on these + note them as dependencies in packer.nvim
  use("nvim-lua/popup.nvim")
  use("nvim-lua/plenary.nvim")
  use("MunifTanjim/nui.nvim")

  use("mattn/emmet-vim")
  use("tpope/vim-commentary")
  use("tpope/vim-vinegar")
  use("tpope/vim-fugitive")
  use("tpope/vim-sleuth")
  use("tpope/vim-eunuch")
  use("tpope/vim-unimpaired")
  use("thinca/vim-visualstar")
  use("mileszs/ack.vim")
  use("farmergreg/vim-lastplace")
  use("kylechui/nvim-surround")

  use("windwp/nvim-autopairs")
  use("akinsho/toggleterm.nvim")

  use("neovim/nvim-lspconfig")
  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local ts_update = require("nvim-treesitter.install").update({})
      ts_update()
    end,
  })
  use("nvim-treesitter/playground")
  use({
    "nvim-treesitter/nvim-treesitter-textobjects",
    after = "nvim-treesitter",
    requires = "nvim-treesitter/nvim-treesitter",
  })

  -- COLOURS + THEMES
  use("folke/lsp-colors.nvim")
  use("tjdevries/colorbuddy.vim")
  use("Th3Whit3Wolf/onebuddy")
  use({ "catppuccin/nvim", as = "catppuccin" })
  use("sekke276/dark_flat.nvim")

  use("L3MON4D3/LuaSnip")

  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-vsnip")
  use("hrsh7th/cmp-path")
  use("hrsh7th/nvim-cmp")
  use("hrsh7th/cmp-nvim-lua")
  use("echasnovski/mini.files")
  use("saadparwaiz1/cmp_luasnip")

  use("ojroques/vim-oscyank")

  use("numToStr/FTerm.nvim")
  use("SmiteshP/nvim-navic")
  -- use("google/executor.nvim")
  use("~/git/executor.nvim")
  use("jackfranklin/winbar.nvim")
  use("ibhagwan/fzf-lua")
  use("jose-elias-alvarez/null-ls.nvim")
  use("kassio/neoterm")
  use("rlane/pounce.nvim")
end

return M
