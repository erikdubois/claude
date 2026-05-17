#!/usr/bin/env bash
f=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$f" ] && exit 0
echo "$f" | grep -qE '\.py$' || exit 0
result=$(flake8 "$f" --max-line-length=120 --ignore=E402,W503,W504,E128,E203 2>&1)
[ -z "$result" ] && exit 0
jq -n --arg f "$f" --arg r "$result" \
  '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":("flake8 issues in "+$f+":\n"+$r+"\nFix these automatically.")}}'
