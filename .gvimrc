" command t use Command-T
if has("gui_macvim")
  macmenu &File.New\ Tab key=<nop>
  map <D-t> :CommandT<CR>
endif

" hide MacVim toolbar
if has("gui_running")
  set guioptions-=T
endif
