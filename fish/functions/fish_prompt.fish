function fish_prompt
    set_color red
    echo -n (basename $PWD)
    set_color normal
    set -l jobs (suspended-jobs)
    if test -n "$jobs"
        set_color yellow
        echo -n " [$jobs]"
        set_color normal
    end
    echo -n ' > '
end
