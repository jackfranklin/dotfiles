require("nvim-treesitter.configs").setup({
  ensure_installed = "all",
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "vv",
      node_incremental = "v",
      node_decremental = "V",
    },
  },
})
