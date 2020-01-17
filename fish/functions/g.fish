function g
  if count $argv > /dev/null
    git $argv
  else
    git status -sb
  end
end
