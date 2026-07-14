local ensure_installed_langs = {
  "c",
  "comment",
  "cpp",
  "css",
  "csv",
  "elm",
  "fish",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "gn",
  "html",
  "javascript",
  "json",
  "json5",
  -- "jsonc", -- not currently supported in nvim-treesitter
  "lua",
  "luadoc",
  "make",
  "markdown",
  "markdown_inline",
  "ninja",
  "python",
  "ruby",
  "rust",
  "scss",
  "sql",
  "ssh_config",
  "svelte",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

local tree = require("nvim-treesitter")

tree.setup()

local ignored_filetypes = {
  fzf = true,
  fugitive = true,
  conf = true,
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    if ignored_filetypes[ft] then
      return
    end
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then
      return
    end
    local installed = require("nvim-treesitter.config").get_installed()
    if vim.tbl_contains(installed, lang) then
      vim.treesitter.start()
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    elseif vim.tbl_contains(ensure_installed_langs, lang) then
      vim.notify("No treesitter parser installed for: " .. lang, vim.log.levels.WARN)
    end
  end,
})
local alreadyInstalled = require("nvim-treesitter.config").get_installed()
local parsersToInstall = vim
  .iter(ensure_installed_langs)
  :filter(function(parser)
    return not vim.tbl_contains(alreadyInstalled, parser)
  end)
  :totable()
require("nvim-treesitter").install(parsersToInstall)

require("treesitter-context").setup({
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 1, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to show for a single context
  trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
})
vim.keymap.set("n", "gx", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true, desc = "[g]o to the conte[x]t" })
