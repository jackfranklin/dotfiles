function tm-routemaster
  set -l session routemaster
  set -l dir ~/git/routemaster

  if not tmux has-session -t $session 2>/dev/null
    tmux new-session -d -s $session -c $dir
    tmux new-window -t $session -c $dir 'npm run dev'
    tmux select-window -t $session:1
  end

  if test -n "$TMUX"
    tmux switch-client -t $session
  else
    tmux attach-session -t $session
  end
end
