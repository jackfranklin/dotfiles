function! JF_ExecuteCurrentFile()
  silent write
  let filename = expand("%")
  if match(filename, '\.rb') != -1
    if match(filename, '_spec') != -1
      exec '!rspec %'
    elseif match(filename, '_test') != -1
      exec '!ruby -Itest %'
    else
      exec '!ruby %'
    endif
    return
  endif
  if match(filename, '\.js') != -1
    let fullpath = expand('%:p')
    if match(fullpath, 'test') != -1 || match(fullpath, 'spec') != -1
      " search the PWD for a package.json. If there is one, high chance we're
      " in an npm project with npm test defined
      let searchForPackageJsonOutput = system('find . -name "package.json" -depth 1 2>/dev/null')
      if match(searchForPackageJsonOutput, './package.json') != -1
        exec '!npm test'
      else
        exec '!node %'
      endif
    else
      exec '!node %'
    endif
    return
  endif
endfunction
