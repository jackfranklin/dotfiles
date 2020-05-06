" To use, save this file and type ":so %"
"
" There are some sort options at the end you can uncomment to your preference
"
" Create a new scratch buffer:
" - Read file $VIMRUNTIME/rgb.txt
" - Delete lines where color name is not a single word (duplicates).
" - Delete "grey" lines (duplicate "gray"; there are a few more "gray").
" Add syntax so each color name is highlighted in its color.
new
setlocal buftype=nofile bufhidden=hide noswapfile
0read $VIMRUNTIME/rgb.txt
let find_color = '^\s*\(\d\+\s*\)\{3}\zs\w*$'
silent execute 'v/'.find_color.'/d'
silent g/grey/d
let namedcolors=[]
1
while search(find_color, 'W') > 0
    let w = expand('<cword>')
    call add(namedcolors, w)
endwhile

for w in namedcolors
    execute 'hi col_'.w.' guifg=black guibg='.w
    execute 'hi col_'.w.'_fg guifg='.w.' guibg=NONE'
    execute '%s/\<'.w.'\>/'.printf("%-36s%s", w, w.'_fg').'/g'

    execute 'syn keyword col_'.w w
    execute 'syn keyword col_'.w.'_fg' w.'_fg'
endfor

" Add hex value column (and format columns nicely)
%s/^\s*\(\d\+\)\s\+\(\d\+\)\s\+\(\d\+\)\s\+/\=printf(" %3d %3d %3d   #%02x%02x%02x   ", submatch(1), submatch(2), submatch(3), submatch(1), submatch(2), submatch(3))/

" Sort by RGB value (uncomment the following 'sort' line)
" sort ui

" Sort by color name (uncomment the following 'sort' line)
" (Unfortunately, can't do 'natural' order, where 'gray2' precedes 'gray19')
" sort ui /^\s*\(\d\+\s*\)\{3}#\x\+\s*/

1
nohlsearch
