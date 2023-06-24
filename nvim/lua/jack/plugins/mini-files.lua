local icons = require("nvim-web-devicons")

icons.set_default_icon("-", "#6d8086", 65)
icons.setup({
  default = true,
})

local icons_list = require("nvim-web-devicons").get_icons()
for key, value in pairs(icons_list) do
  require("nvim-web-devicons").set_icon({
    [key] = vim.tbl_extend("force", value, { icon = "-" }),
  })
end

require("mini.files").setup()
