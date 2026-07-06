# Fuzzy select and switch/attach to a tmux session
function tms --description 'Fuzzy select and switch/attach to a tmux session'
    set -l session (tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0)
    if test -n "$session"
        if set -q TMUX
            tmux switch-client -t $session
        else
            tmux attach-session -t $session
        end
    end
end
