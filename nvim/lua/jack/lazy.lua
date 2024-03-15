local M = {}
M.run_lazy = function(plugins)
  local opts = {}

  M.ensure_lazy_installed()
  M.set_leader()

  require("lazy").setup(plugins, opts)
end

M.set_leader = function()
  vim.g.mapleader = " "
end

M.ensure_lazy_installed = function()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)
end

return M
