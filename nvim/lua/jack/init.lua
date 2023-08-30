local plugins = require("jack.plugins")
local M = {}

M.packer = function()
  return require("packer").startup(function(use)
    plugins.load_plugins(use)
  end)
end

M.run_lazy = function(extra_plugins)
  local opts = {}

  local final_plugins = vim.tbl_deep_extend("error", plugins.default(), extra_plugins or {})
  require("lazy").setup(final_plugins, opts)
end

M.ensure_packer_installed = function()
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
