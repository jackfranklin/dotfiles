function __jack_ctrl_d
  if test -z (commandline)
    echo
    echo "Ctrl-D disabled to avoid accidentally closing the terminal — type 'exit' instead."
    commandline -f repaint
  else
    commandline -f delete-char
  end
end

function fish_user_key_bindings
  fzf --fish | source
  bind \cd __jack_ctrl_d
end
