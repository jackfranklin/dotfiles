require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"lua",
		"rust",
		"tsx",
		"javascript",
		"typescript",
		"css",
		"markdown",
		"html",
		"fish",
		"jsdoc",
		"make",
		"svelte",
		"yaml",
		"comment",
	},
	sync_install = true,
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "vv",
			node_incremental = "v",
			node_decremental = "V",
		},
	},
})
