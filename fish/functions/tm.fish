# Create or attach to a tmux session
# the session will be named automatically based on the PWD
function tm
  tmux new-session -A -s (basename $PWD)
end
