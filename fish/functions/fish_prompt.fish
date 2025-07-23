function fish_prompt
    set_color red
    echo -n (basename $PWD)
    set_color normal
    echo -n ' > '
end
