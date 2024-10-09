local goto_preview = require("goto-preview")

goto_preview.setup({
  post_open_hook = function(buff, win)
    vim.keymap.set("n", "q", function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end, { buffer = buff })
  end,
})

vim.keymap.set("n", "gp", function()
  goto_preview.goto_preview_definition()
end, { desc = "LSP [g]oto [p]review" })

vim.keymap.set("n", "<leader>wl", "<C-w>L", {
  desc = "Move [window] to right hand split",
})
