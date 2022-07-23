require('neo-tree').setup({
  default_component_configs = {
    icon = {
      folder_closed = ">",
      folder_open = "v",
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = false,
      highlight = "NeoTreeFileName",
    },
    git_status = {
      symbols = {
        -- Change type
        added     = "+", -- or "✚", but this is redundant info if you use git_status_colors on the name
        modified  = "~", -- or "", but this is redundant info if you use git_status_colors on the name
        deleted   = "x",-- this can only be used in the git_status source
        renamed   = "r",-- this can only be used in the git_status source
        -- Status type
        untracked = "",
        ignored   = "i",
        unstaged  = "u",
        staged    = "-",
        conflict  = "=",
      },
    },
  },
  filesystem = {
    window = {
      mappings = {
        ["U"] = "navigate_up",
        ["."] = "set_root",
        ["H"] = "toggle_hidden",
        ["/"] = "fuzzy_finder",
        ["D"] = "fuzzy_finder_directory",
        ["f"] = "filter_on_submit",
        ["<c-x>"] = "clear_filter",
        ["[g"] = "prev_git_modified",
        ["]g"] = "next_git_modified",
      }
    }
  }
})
