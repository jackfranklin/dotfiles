lua require('jack.init').packer()
lua require('jack.base-settings')
lua require('jack.maps')
lua require('jack.plugins.winbar')
lua require('jack.theme')

lua require('jack.plugins.ack')
lua require('jack.plugins.autopairs')
lua require('jack.plugins.cmp')
lua require('jack.plugins.executor').setup({})
lua require('jack.plugins.emmet-vim')
lua require('jack.plugins.fterm').setup({})
lua require('jack.plugins.fugitive')
lua require('jack.plugins.fzf-lua').setup({})
lua require('jack.plugins.lsp')
lua require('jack.plugins.neoterm')
lua require('jack.plugins.snippets')
lua require('jack.plugins.statusline')
lua require('jack.plugins.surround')
lua require('jack.plugins.treesitter')

lua << EOF
local config = require('config_paths')
local formatter = require('jack.plugins.formatter').setup({
  prettier_path = config.prettier_path(),
})
formatter.configure_formatters()
EOF
