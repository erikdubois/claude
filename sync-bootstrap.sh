#!/usr/bin/env bash
# Syncs live ~/.claude/ config into this bootstrap folder.
# Run at session start (wired into hooks/session-start.sh) or manually.
set -euo pipefail

BOOTSTRAP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE="$HOME/.claude"
GLOBAL_MEM="$CLAUDE/projects/-home-erik/memory"
CHANGED=0

mark_changed() { CHANGED=1; }

# ── CLAUDE.md ────────────────────────────────────────────────
if ! diff -q "$CLAUDE/CLAUDE.md" "$BOOTSTRAP/CLAUDE.md" &>/dev/null; then
    cp "$CLAUDE/CLAUDE.md" "$BOOTSTRAP/CLAUDE.md"
    mark_changed
fi

# ── settings.json ────────────────────────────────────────────
# Not synced — bootstrap/settings.json is a clean generic template.
# The live ~/.claude/settings.json contains project-specific allow rules
# that don't belong in the bootstrap.

# ── hooks ────────────────────────────────────────────────────
for hook in flake8-hook.sh statusline.sh session-start.sh; do
    src="$CLAUDE/hooks/$hook"
    dst="$BOOTSTRAP/hooks/$hook"
    [ -f "$src" ] || continue
    if ! diff -q "$src" "$dst" &>/dev/null 2>&1; then
        cp "$src" "$dst"
        chmod +x "$dst"
        mark_changed
    fi
done

# ── commands ─────────────────────────────────────────────────
if [ -d "$CLAUDE/commands" ]; then
    mkdir -p "$BOOTSTRAP/commands"
    for cmd_file in "$CLAUDE/commands/"*.md; do
        [ -f "$cmd_file" ] || continue
        name=$(basename "$cmd_file")
        dst="$BOOTSTRAP/commands/$name"
        if ! diff -q "$cmd_file" "$dst" &>/dev/null 2>&1; then
            cp "$cmd_file" "$dst"
            mark_changed
        fi
    done
fi

# ── skills ───────────────────────────────────────────────────
for skill_dir in "$CLAUDE/skills"/*/; do
    name=$(basename "$skill_dir")
    dst="$BOOTSTRAP/skills/$name"
    src_skill="$skill_dir/SKILL.md"
    dst_skill="$dst/SKILL.md"
    [ -f "$src_skill" ] || continue
    mkdir -p "$dst"
    if ! diff -q "$src_skill" "$dst_skill" &>/dev/null 2>&1; then
        cp "$src_skill" "$dst_skill"
        mark_changed
    fi
done

# ── best_practices.md (sanitize personal paths) ──────────────
sanitized=$(sed \
    -e 's|linux-lqx|<package>|g' \
    -e 's|/home/erik/\.bin/[^ ]*|~/.bin/<your-script>|g' \
    -e 's|erikdubois/[^ ]*|<owner>/<repo>|g' \
    "$CLAUDE/best_practices.md")
if [ "$sanitized" != "$(cat "$BOOTSTRAP/best_practices.md")" ]; then
    echo "$sanitized" > "$BOOTSTRAP/best_practices.md"
    mark_changed
fi

# ── memory — update existing files from global memory ────────
if [ -d "$GLOBAL_MEM" ]; then
    for dst_file in "$BOOTSTRAP/memory/"*.md; do
        name=$(basename "$dst_file")
        [ "$name" = "MEMORY.md" ] && continue
        src_file="$GLOBAL_MEM/$name"
        [ -f "$src_file" ] || continue
        if ! diff -q "$src_file" "$dst_file" &>/dev/null; then
            cp "$src_file" "$dst_file"
            mark_changed
        fi
    done
fi

# ── commit if anything changed ───────────────────────────────
if [ "$CHANGED" -eq 1 ]; then
    cd "$BOOTSTRAP"
    git -C "$BOOTSTRAP" rev-parse --git-dir > /dev/null 2>&1 || { echo "bootstrap not a git repo — skipping commit"; exit 0; }
    git add -A
    git commit -m "chore: sync bootstrap from ~/.claude/ ($(date +%Y-%m-%d))"
    echo "bootstrap synced and committed"
fi
