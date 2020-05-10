function xrandr-laptop-off
  if which xrandr > /dev/null
    xrandr --output eDP-1 --off
    echo "Turned laptop display off"
  end
end
