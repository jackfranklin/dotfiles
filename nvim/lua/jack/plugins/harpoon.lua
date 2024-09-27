local M = {}

function harpoon_desc(txt)
  return "[h]arpoon " .. txt
end
M.setup = function()
  require("harpoon").setup({
    menu = {
      width = math.floor(vim.api.nvim_win_get_width(0) * 4 / 5),
    },
    global_settings = {
      mark_branch = true,
    },
  })

  vim.keymap.set({ "n" }, "<leader>ha", function()
    require("harpoon.mark").add_file()
  end, { desc = harpoon_desc("[a]dd") })

  vim.keymap.set({ "n" }, "<leader>hr", function()
    require("harpoon.mark").rm_file()
  end, { desc = harpoon_desc("[r]emove") })

  vim.keymap.set({ "n" }, "<leader>hq", function()
    require("harpoon.mark").clear_all()
  end, { desc = harpoon_desc("[q] clear all") })

  vim.keymap.set({ "n" }, "<leader>hl", function()
    require("harpoon.ui").toggle_quick_menu()
  end, { desc = harpoon_desc("[l]ist") })

  vim.keymap.set({ "n" }, "<leader>hn", function()
    require("harpoon.ui").nav_next()
  end, { desc = harpoon_desc("[n]ext") })

  vim.keymap.set({ "n" }, "<leader>hp", function()
    require("harpoon.ui").nav_prev()
  end, { desc = harpoon_desc("[p]rev") })

  vim.keymap.set({ "n" }, "<leader>h1", function()
    require("harpoon.ui").nav_file(1)
  end, { desc = harpoon_desc("[1]st file") })
  vim.keymap.set({ "n" }, "<leader>h2", function()
    require("harpoon.ui").nav_file(2)
  end, { desc = harpoon_desc("[2]nd file") })
  vim.keymap.set({ "n" }, "<leader>h3", function()
    require("harpoon.ui").nav_file(3)
  end, { desc = harpoon_desc("[3]rd file") })
  vim.keymap.set({ "n" }, "<leader>h4", function()
    require("harpoon.ui").nav_file(4)
  end, { desc = harpoon_desc("[4]th file") })
end

return M
