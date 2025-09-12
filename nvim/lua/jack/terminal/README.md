# Terminal Plugin for Neovim

A flexible terminal management plugin for Neovim that supports both floating and split terminal windows with advanced configuration options.

## Features

- **Side Terminal**: Persistent terminal that can be toggled on/off
- **Custom Terminals**: Create terminals in split or floating windows
- **Floating Terminals**: Floating windows with configurable size, position, and styling
- **Command Execution**: Run commands in terminals with optional auto-close
- **Smart Persistence**: Terminals stay open after commands complete by default
- **Percentage Sizing**: Use percentages (0.0-1.0) or absolute values for window dimensions
- **Auto-centering**: Automatically center floating windows
- **Border Styling**: Multiple border styles and optional titles

## Installation

### Using Lazy.nvim
```lua
{
  "your-username/terminal.nvim",
  config = function()
    require("jack.terminal").setup()
  end
}
```

### Manual Installation
Clone this repository into your Neovim configuration directory and require it:
```lua
require("jack.terminal").setup()
```

## API Reference

### Core Functions

#### `toggle_side_terminal()`
Toggles the persistent side terminal (vertical split).
```lua
require("jack.terminal").toggle_side_terminal()
```

#### `create_custom_terminal(config)`
Creates a custom terminal with specified configuration.
```lua
-- Vertical split with htop
local terminal = require("jack.terminal").create_custom_terminal({
  cmd = "htop",
  window = { type = "split", split_direction = "vertical" }
})

-- Horizontal split 
local terminal = require("jack.terminal").create_custom_terminal({
  cmd = "npm run dev",
  window = { type = "split", split_direction = "horizontal" }
})

-- Floating window
local terminal = require("jack.terminal").create_custom_terminal({
  cmd = "bash",
  window = {
    type = "float",
    width = 0.8,
    height = 0.6,
    row = "center",
    col = "center",
    border = "rounded",
    title = "Development Terminal"
  }
})
```

#### `create_floating_terminal(config)`
Creates a floating terminal (convenience function).
```lua
-- Basic floating terminal
local terminal = require("jack.terminal").create_floating_terminal({
  window = { width = 0.8, height = 0.6, row = "center", col = "center" }
})

-- With command and custom styling
local terminal = require("jack.terminal").create_floating_terminal({
  cmd = "htop",
  window = {
    width = 100,          -- 100 columns
    height = 30,          -- 30 rows
    row = 5,              -- 5 rows from top
    col = 10,             -- 10 columns from left
    border = "double",
    title = "System Monitor"
  }
})

-- Command that closes terminal when done
local terminal = require("jack.terminal").create_floating_terminal({
  cmd = "ls -la",
  close_on_exit = true,
  window = { width = 0.7, height = 0.5, row = "center", col = "center" }
})
```

#### `toggle_floating_terminal(terminal_info, window_config)`
Toggles the visibility of a floating terminal.
```lua
local terminal = require("jack.terminal").create_floating_terminal({
  window = { width = 0.8, height = 0.6 }
})

-- Later, toggle it on/off
terminal = require("jack.terminal").toggle_floating_terminal(terminal, {
  width = 0.8, height = 0.6, row = "center", col = "center"
})
```

## Configuration Options

### Window Configuration
```lua
window = {
  type = "float",                    -- "split" or "float"
  
  -- For split windows:
  split_direction = "vertical",      -- "vertical" or "horizontal"
  
  -- For floating windows:
  width = 0.8,                       -- Number: columns or percentage (0.0-1.0)
  height = 0.6,                      -- Number: rows or percentage (0.0-1.0) 
  row = "center",                    -- Number: 0-based position or "center"
  col = "center",                    -- Number: 0-based position or "center"
  border = "rounded",                -- Border style (see below)
  title = "My Terminal"              -- Optional window title
}
```

### Border Styles
- `"none"` - No border
- `"single"` - Single line border
- `"double"` - Double line border  
- `"rounded"` - Rounded corners (default)
- `"solid"` - Solid border
- `"shadow"` - Drop shadow effect

### Command Options
```lua
{
  cmd = "htop",                      -- Command to run
  close_on_exit = false,             -- Keep terminal open after command (default: false)
  window = { ... }                   -- Window configuration
}
```

## Default Keymaps

The plugin sets up one default keymap:
- `<leader>pp` - Toggle side terminal

## Usage Examples

### Basic Side Terminal
```lua
-- Setup with default keymap
require("jack.terminal").setup()

-- Toggle with <leader>pp or programmatically
require("jack.terminal").toggle_side_terminal()
```

### Development Workflow
```lua
local terminal = require("jack.terminal")

-- Main development terminal (floating)
local dev_term = terminal.create_floating_terminal({
  cmd = "bash",
  window = {
    width = 0.9,
    height = 0.7,
    row = "center", 
    col = "center",
    border = "rounded",
    title = "Development"
  }
})

-- Quick command terminal (auto-closes)
terminal.create_floating_terminal({
  cmd = "git status",
  close_on_exit = true,
  window = { width = 0.6, height = 0.4, row = "center", col = "center" }
})

-- System monitor (horizontal split)
terminal.create_custom_terminal({
  cmd = "htop",
  window = { type = "split", split_direction = "horizontal" }
})
```

### Toggle Management
```lua
-- Create a persistent floating terminal
local my_terminal = terminal.create_floating_terminal({
  window = { width = 0.8, height = 0.6, row = "center", col = "center" }
})

-- Create keymap to toggle it
vim.keymap.set("n", "<leader>ft", function()
  my_terminal = terminal.toggle_floating_terminal(my_terminal)
end, { desc = "Toggle floating terminal" })
```

## Requirements

- Neovim 0.7+
- Works on all platforms (Linux, macOS, Windows)

## License

MIT License