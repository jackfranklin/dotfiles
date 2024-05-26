require("nvim-treesitter.configs").setup({
  ignore_install = {},
  sync_install = false,
  auto_install = true,
  ensure_installed = {
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
    "html",
    "javascript",
    "json",
    "json5",
    "jsonc",
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
  },
  highlight = {
    enable = true,
  },
  indent = {
    enable = false,
  },

  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
        -- You can also use captures from other query groups like `locals.scm`
        ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      include_surrounding_whitespace = true,
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist

      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = { query = "@class.outer", desc = "Next class start" },
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
    },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "vv",
      node_incremental = "+",
      node_decremental = "=",
    },
  },
  -- silences Lua-LS lint errors.
  modules = {},
})

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
