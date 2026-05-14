local diff = require("mini.diff")

diff.setup({})

vim.keymap.set("n", "<leader>ghd", function()
  diff.toggle_overlay()
end, { desc = "view [g]it [h]unk [d]iff" })

vim.keymap.set("n", "<leader>ghb", function()
  vim.ui.input({ prompt = "Git ref to diff against: " }, function(input)
    if input and input ~= "" then
      local lines = vim.fn.systemlist("git show " .. input .. ":./" .. vim.fn.expand("%"))
      if vim.v.shell_error == 0 then
        diff.set_ref_text(0, lines)
        print("Diffing against " .. input)
      else
        print("Could not find ref: " .. input)
      end
    end
  end)
end, { desc = "set git [h]unk [b]ase" })

vim.keymap.set("n", "<leader>ghr", function()
  diff.set_ref_text(0, {})
  print("Reset diff base to index")
end, { desc = "[g]it [h]unk [r]eset base" })
