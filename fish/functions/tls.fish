function tls
  tmux list-sessions | sed -E 's/:.*$//'
end
