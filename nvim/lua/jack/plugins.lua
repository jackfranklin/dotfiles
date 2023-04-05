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

  -- use({ "junegunn/fzf", run = ":call fzf#install()" })
  -- use("junegunn/fzf.vim")

  use("mhartington/formatter.nvim")
  use("windwp/nvim-autopairs")

  use("neovim/nvim-lspconfig")
  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
      ts_update()
    end,
    config = function()
      -- Ensure folds function: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
      -- vim.api.nvim_exec(
      --   [[
      -- function FoldConfig()
      -- set foldmethod=expr
      -- set foldexpr=nvim_treesitter#foldexpr()
      -- endfunction
      -- autocmd BufAdd,BufEnter,BufNew,BufNewFile,BufWinEnter * :call FoldConfig()
      -- ]],
      --   false
      -- )
    end,
  })
  use("nvim-treesitter/playground")

  -- COLOURS + THEMES
  use("folke/lsp-colors.nvim")
  use("tjdevries/colorbuddy.vim")
  use("Th3Whit3Wolf/onebuddy")
  use({ "catppuccin/nvim", as = "catppuccin" })

  use("L3MON4D3/LuaSnip")

  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-vsnip")
  use("hrsh7th/cmp-path")
  use("hrsh7th/nvim-cmp")
  use("hrsh7th/cmp-nvim-lua")
  use("saadparwaiz1/cmp_luasnip")

  use("kassio/neoterm")
  use("ojroques/vim-oscyank")

  use("numToStr/FTerm.nvim")
  use("SmiteshP/nvim-navic")
  use("google/executor.nvim")
  use("jackfranklin/winbar.nvim")
  use("ibhagwan/fzf-lua")
end

return M
