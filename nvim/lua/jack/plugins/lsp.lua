local nvim_lsp = require("lspconfig")
local util = require("lspconfig.util")
local config_paths = require("config_paths")
local on_attach = require("lsp_on_attach").on_attach

-- Add a border around floating diagnostic windows.
local _border = "single"
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = _border,
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = _border,
})

vim.diagnostic.config({
	float = { border = _border },
})

local cmp = require("cmp")
cmp.setup({
	completion = {
		completeopt = "menu,menuone,noinsert",
	},
	snippet = {
		expand = function(args)
			-- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` user.
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = {
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.close(),
		["<C-y>"] = cmp.mapping(
			cmp.mapping.confirm({
				behavior = cmp.ConfirmBehavior.Insert,
				select = true,
			}),
			{ "i", "c" }
		),
		["<C-n>"] = {
			i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
		},
		["<C-p>"] = {
			i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
		},
	},
	sources = {
		{ name = "nvim_lsp", max_item_count = 10 },
		{ name = "path", keyword_length = 3, max_item_count = 10 },
		{ name = "luasnip", max_item_count = 5 },
		{ name = "buffer", max_item_count = 10, keyword_length = 4 },
		{ name = "nvim_lua", max_item_count = 4, keyword_length = 2 },
	},
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local tsserver_command = config_paths.typescript_lsp_cmd()

if tsserver_command ~= nil then
	nvim_lsp.tsserver.setup({
		on_attach = on_attach,
		filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
		cmd = tsserver_command,
		capabilities = capabilities,
	})
end

nvim_lsp.elmls.setup({
	root_dir = function(name)
		return util.root_pattern("elm.json")(name)
	end,
	on_attach = on_attach,
})

nvim_lsp.svelte.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

nvim_lsp.rust_analyzer.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		["rust-analyzer"] = {
			checkOnSave = {
				command = "clippy",
			},
			completion = {
				addCallParenthesis = true,
				addCallArgumentSnippets = true,
			},
		},
	},
})

nvim_lsp.eslint.setup({
	root_dir = function(name)
		return util.root_pattern("tsconfig.json")(name)
	end,
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = false,
	signs = false,
	update_in_insert = false,
})

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

nvim_lsp.sumneko_lua.setup({
	on_attach = on_attach,
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
				-- Setup your lua path
				path = runtime_path,
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
})
