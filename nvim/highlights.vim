highlight CursorLine cterm=none ctermbg=16 guibg=gray17
highlight Comment cterm=italic gui=italic

" PMenu = pop up menu when auto-completing
highlight PMenuSel ctermfg=0 ctermbg=13 guibg=LightGray guifg=Black
highlight PMenu ctermfg=255 ctermbg=0 guibg=DarkSlateGray guifg=White

highlight MatchParen ctermfg=255 ctermbg=240
highlight ALEError ctermbg=none cterm=underline ctermfg=1 guifg=IndianRed gui=underline
highlight ALEWarning ctermbg=none cterm=underline ctermfg=184 guifg=LightGoldrenrod gui=underline

if (has('termguicolors'))
    highlight EndOfBuffer guifg=gray80
    highlight Visual guibg=gray25

    highlight typescriptProp guifg=SeaGreen

    highlight Whitespace guifg=gray90
endif
