require("gitsigns").setup({
  signcolumn = false,
  on_attach = function()
    local gs = package.loaded.gitsigns

    vim.keymap.set("n", "<leader>ghp", gs.preview_hunk)
  end,
})
