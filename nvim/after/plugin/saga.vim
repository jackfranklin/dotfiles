lua << EOF
local saga = require 'lspsaga'
saga.init_lsp_saga {
  use_saga_diagnostic_sign = false,
  error_sign = '',
  warn_sign = '',
  hint_sign = '',
  infor_sign = '',
  dianostic_header_icon = ''
}
EOF

"note: some of these key bindings are defined in lsp.vim in the on_attach
"function
" scroll down hover doc or scroll in definition preview
nnoremap <silent> <C-f> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>
" scroll up hover doc
nnoremap <silent> <C-b> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>
