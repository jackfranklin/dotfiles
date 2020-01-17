function git-current-branch-name
  git branch 2>/dev/null | grep '^*' | colrm 1 2
end
