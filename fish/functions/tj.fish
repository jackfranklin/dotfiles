function tj
  tmux attach-session -t (tmux list-sessions | sed -E 's/:.*$//' | fzf)
end
