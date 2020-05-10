function xrandr-external-scale
  if which xrandr > /dev/null
    xrandr --output DP-2 --scale 1.5x1.5
  end
end
