function xrandr-laptop-on
  if which xrandr > /dev/null
    xrandr --output eDP-1 --auto
    echo "Turned laptop display on"
  end
end
