local M = {}

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
  -- Pinned pending https://github.com/SmiteshP/nvim-navic/issues/130
  -- use({ "SmiteshP/nvim-navic", commit = "e6da6f74d89de65258ea7e98e22103ff5de6dcf5" })
  use("~/git/nvim-navic")
  -- use("google/executor.nvim")
  use("~/git/executor.nvim")
  use("jackfranklin/winbar.nvim")
  use("ibhagwan/fzf-lua")
  use("jose-elias-alvarez/null-ls.nvim")
  use("kassio/neoterm")
end

return M
