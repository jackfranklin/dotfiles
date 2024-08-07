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
        ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
        ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },

        ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
        ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

        ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
        ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

        ["af"] = { query = "@function.outer", desc = "Select outer part of a method/function definition" },
        ["if"] = { query = "@function.inner", desc = "Select inner part of a method/function definition" },

        ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
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
        ["gaf"] = { query = "@call.outer", desc = "Next function call start" },
        ["gam"] = { query = "@function.outer", desc = "Next method/function def start" },
        ["gac"] = { query = "@class.outer", desc = "Next class start" },
        ["gai"] = { query = "@conditional.outer", desc = "Next conditional start" },
        ["gal"] = { query = "@loop.outer", desc = "Next loop start" },
      },
      goto_previous_start = {
        ["gaF"] = { query = "@call.outer", desc = "Prev function call start" },
        ["gaM"] = { query = "@function.outer", desc = "Prev method/function def start" },
        ["gaC"] = { query = "@class.outer", desc = "Prev class start" },
        ["gaI"] = { query = "@conditional.outer", desc = "Prev conditional start" },
        ["gaL"] = { query = "@loop.outer", desc = "Prev loop start" },
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
vim.keymap.set("n", "gx", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true, desc = "[g]o to the conte[x]t" })
