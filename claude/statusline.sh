#!/usr/bin/env bash
input=$(cat)

GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# Git branch
if git rev-parse --git-dir > /dev/null 2>&1; then
    GIT_PART=$(git branch --show-current 2>/dev/null)
    [ -z "$GIT_PART" ] && GIT_PART="[detached]"
else
    GIT_PART="[no git]"
fi

# Token usage (current context window input tokens)
TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')

format_tokens() {
    local t=$1
    if [ "$t" -lt 1000 ]; then
        echo "${t}"
    elif [ "$t" -lt 10000 ]; then
        local whole=$((t / 1000))
        local tenth=$(( (t % 1000) / 100 ))
        echo "${whole}.${tenth}k"
    else
        echo "$((t / 1000))k"
    fi
}

TOKEN_FMT=$(format_tokens "$TOKENS")

# Color based on proximity to 200k personal limit
if [ "$TOKENS" -ge 160000 ]; then
    TOKEN_COLOR="$RED"
elif [ "$TOKENS" -ge 100000 ]; then
    TOKEN_COLOR="$YELLOW"
else
    TOKEN_COLOR="$GREEN"
fi

echo -e "${GIT_PART}  ${TOKEN_COLOR}${TOKEN_FMT}${RESET}"
