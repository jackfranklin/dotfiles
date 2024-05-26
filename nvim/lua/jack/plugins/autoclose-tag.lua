---@diagnostic disable-next-line: missing-fields
require("nvim-ts-autotag").setup({
  opts = {
    enable_close = false, -- Auto close tags
    enable_rename = true, -- Auto rename pairs of tags
    enable_close_on_slash = true, -- Auto close on trailing </
  },
})
