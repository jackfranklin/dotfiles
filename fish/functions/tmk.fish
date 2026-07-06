# Fuzzy find and kill tmux sessions
function tmk --description 'Fuzzy find and kill tmux sessions'
    set -l sessions (tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --multi --placeholder="Select sessions to kill (Tab to select multiple)")
    if test -n "$sessions"
        echo "$sessions" | while read -l session
            tmux kill-session -t "$session"
            echo "Killed session: $session"
        end
    end
end
