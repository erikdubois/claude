#!/bin/bash
# Read JSON data that Claude Code sends to stdin
input=$(cat)

# Extract fields using jq
MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
# used_percentage is pre-calculated (0-100), null if no messages yet
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
# total cost in USD for the session
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

# Build the status line - ${DIR##*/} extracts just the folder name
STATUS="[${MODEL}] ${DIR##*/}"

if [ -n "$PCT" ]; then
    STATUS="${STATUS} | context: $(printf '%.0f' "$PCT")% used"
fi

if [ -n "$COST" ]; then
    STATUS="${STATUS} | cost: $(printf '$%.4f' "$COST")"
fi

printf "%s\n" "$STATUS"