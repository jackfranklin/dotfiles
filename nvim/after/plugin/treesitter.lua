require'nvim-treesitter.configs'.setup {
  ensure_installed = { "lua", "rust", "javascript", "typescript", "css", "markdown", "html", "fish", "jsdoc", "make", "svelte", "yaml" },
  sync_install = true,
  highlight = {
    enable = true,
  },
  indent = {
    enable = true
  }
}
