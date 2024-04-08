require("mini.files").setup({
  content = {
    -- Empty to remove the icons
    prefix = function() end,
  },
})

-- The first arg is the file to use as the CWD, the second false means it will be a fresh window each time and not remember previous state.
vim.keymap.set("n", "-", function()
  require("mini.files").open(vim.api.nvim_buf_get_name(0), false)
end, { desc = "Open parent directory" })
