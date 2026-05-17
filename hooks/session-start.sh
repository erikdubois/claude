#!/usr/bin/env bash
# Runs at Claude Code session start:
# 1. git pull on the current workspace if it's a git repo
# 2. sync bootstrap folder from ~/.claude/
input=$(cat)
dir=$(echo "$input" | jq -r '.workspace.current_dir // empty' 2>/dev/null)

# ── git pull ─────────────────────────────────────────────────
if [ -n "$dir" ] && git -C "$dir" rev-parse --git-dir > /dev/null 2>&1; then
    result=$(git -C "$dir" pull 2>&1)
    if ! echo "$result" | grep -qE "Already up to date|up-to-date"; then
        jq -n --arg r "$result" \
          '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":("git pull:\n"+$r)}}'
    fi
fi

# ── sync bootstrap ───────────────────────────────────────────
BOOTSTRAP="$HOME/EDU/claude"
if [ -f "$BOOTSTRAP/sync-bootstrap.sh" ]; then
    bash "$BOOTSTRAP/sync-bootstrap.sh" > /dev/null 2>&1 || true
fi
