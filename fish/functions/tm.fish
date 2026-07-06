# Create or attach to a tmux session named after the PWD
function tm --description 'Create or attach to a tmux session named after the PWD'
    # Get current directory name and replace dots with underscores
    set -l dir_name (basename (pwd) | tr '.' '_')

    if tmux has-session -t $dir_name 2>/dev/null
        if set -q TMUX
            tmux switch-client -t $dir_name
        else
            tmux attach-session -t $dir_name
        end
    else
        if set -q TMUX
            tmux new-session -d -s $dir_name
            tmux switch-client -t $dir_name
        else
            tmux new-session -s $dir_name
        end
    end
end
