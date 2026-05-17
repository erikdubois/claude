#!/usr/bin/env bash
set -euo pipefail

# Bootstrap Claude Code config from this folder to ~/.claude/
# Usage: ./bootstrap.sh [--project /path/to/project]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

GREEN=$(tput setaf 2); CYAN=$(tput setaf 6); YELLOW=$(tput setaf 3); RESET=$(tput sgr0)
ok()   { echo "${GREEN}  ✓ $1${RESET}"; }
info() { echo "${CYAN}  → $1${RESET}"; }
warn() { echo "${YELLOW}  ⚠ $1${RESET}"; }

echo ""
echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo "${CYAN}  Claude Code Bootstrap${RESET}"
echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# ── Dependencies ─────────────────────────────────────────────

info "Checking dependencies"

# ── Official repo packages ────────────────────────────────────
pacman_missing=()
command -v flake8   &>/dev/null || pacman_missing+=("python-flake8")
command -v jq       &>/dev/null || pacman_missing+=("jq")
command -v git      &>/dev/null || pacman_missing+=("git")
command -v node     &>/dev/null || pacman_missing+=("nodejs" "npm")
command -v vulture  &>/dev/null || pacman_missing+=("python-vulture")

if [[ ${#pacman_missing[@]} -gt 0 ]]; then
    info "Installing via pacman: ${pacman_missing[*]}"
    sudo pacman -S --needed --noconfirm "${pacman_missing[@]}"
    ok "pacman packages installed"
else
    ok "pacman dependencies already present"
fi

# ── Claude Code CLI ───────────────────────────────────────────
if ! command -v claude &>/dev/null; then
    info "Installing Claude Code CLI"
    npm install -g @anthropic/claude-code
    ok "Claude Code CLI installed"
else
    ok "Claude Code CLI already installed ($(claude --version 2>/dev/null || echo 'version unknown'))"
fi

# ── Claude Code VS Code extension ─────────────────────────────
if command -v code &>/dev/null; then
    if ! code --list-extensions 2>/dev/null | grep -qi "claude"; then
        info "Installing Claude Code VS Code extension"
        code --install-extension anthropic.claude-code
        ok "Claude Code VS Code extension installed"
    else
        ok "Claude Code VS Code extension already installed"
    fi
else
    warn "VS Code not found — skipping extension install (install visual-studio-code-bin first)"
fi

# ── AUR packages ──────────────────────────────────────────────
aur_missing=()
command -v code &>/dev/null || aur_missing+=("visual-studio-code-bin")

if [[ ${#aur_missing[@]} -gt 0 ]]; then
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
    else
        warn "No AUR helper found — install yay or paru first, then re-run"
        warn "Skipping AUR packages: ${aur_missing[*]}"
        AUR_HELPER=""
    fi

    if [[ -n "$AUR_HELPER" ]]; then
        info "Installing via $AUR_HELPER: ${aur_missing[*]}"
        "$AUR_HELPER" -S --needed --noconfirm "${aur_missing[@]}"
        ok "AUR packages installed"
    fi
else
    ok "AUR dependencies already present"
fi

# ── Global config ────────────────────────────────────────────

info "Installing global config to $CLAUDE_DIR/"
mkdir -p "$CLAUDE_DIR"

cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
ok "CLAUDE.md"

# settings.json: merge if exists, overwrite if not
if [[ -f "$CLAUDE_DIR/settings.json" ]]; then
    warn "settings.json already exists — backing up to settings.json.bak"
    cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bak"
fi
cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
ok "settings.json"

if [[ ! -f "$CLAUDE_DIR/settings.local.json" ]]; then
    cp "$SCRIPT_DIR/settings.local.json" "$CLAUDE_DIR/settings.local.json"
    ok "settings.local.json"
else
    warn "settings.local.json already exists — skipped (edit manually)"
fi

# ── Hook scripts ─────────────────────────────────────────────

info "Installing hook scripts"
mkdir -p "$CLAUDE_DIR/hooks"
cp "$SCRIPT_DIR/hooks/flake8-hook.sh"   "$CLAUDE_DIR/hooks/flake8-hook.sh"
cp "$SCRIPT_DIR/hooks/statusline.sh"    "$CLAUDE_DIR/hooks/statusline.sh"
cp "$SCRIPT_DIR/hooks/session-start.sh" "$CLAUDE_DIR/hooks/session-start.sh"
# Keep flat copies for backwards compat (settings.json references ~/.claude/flake8-hook.sh)
cp "$SCRIPT_DIR/hooks/flake8-hook.sh" "$CLAUDE_DIR/flake8-hook.sh"
cp "$SCRIPT_DIR/hooks/statusline.sh"  "$CLAUDE_DIR/statusline.sh"
chmod +x "$CLAUDE_DIR/hooks/"*.sh "$CLAUDE_DIR/flake8-hook.sh" "$CLAUDE_DIR/statusline.sh"
ok "hooks/: flake8-hook.sh, statusline.sh, session-start.sh (executable)"

# ── Skills ───────────────────────────────────────────────────

info "Installing global skills"
mkdir -p "$CLAUDE_DIR/skills"
cp -r "$SCRIPT_DIR/skills/"* "$CLAUDE_DIR/skills/"
ok "skills/: session-start, session-end"

# ── Best practices ───────────────────────────────────────────

info "Installing best_practices.md"
if [[ -f "$CLAUDE_DIR/best_practices.md" ]]; then
    warn "best_practices.md already exists — backing up to best_practices.md.bak"
    cp "$CLAUDE_DIR/best_practices.md" "$CLAUDE_DIR/best_practices.md.bak"
fi
cp "$SCRIPT_DIR/best_practices.md" "$CLAUDE_DIR/best_practices.md"
ok "best_practices.md"

# ── Project setup (optional) ──────────────────────────────────

PROJECT=""
if [[ "${1:-}" == "--project" && -n "${2:-}" ]]; then
    PROJECT="$2"
fi

if [[ -z "$PROJECT" ]]; then
    echo ""
    echo "  Global config installed. To also set up a project:"
    echo "  ${CYAN}$0 --project /path/to/your/project${RESET}"
    echo ""
    exit 0
fi

if [[ ! -d "$PROJECT" ]]; then
    echo "  Project directory not found: $PROJECT"
    exit 1
fi

echo ""
info "Setting up project: $PROJECT"
mkdir -p "$PROJECT/.claude/memory"

# Copy memory files
cp "$SCRIPT_DIR/memory/"*.md "$PROJECT/.claude/memory/"
ok "memory/*.md → $PROJECT/.claude/memory/"

# Copy CLAUDE.md template if none exists
if [[ ! -f "$PROJECT/CLAUDE.md" ]]; then
    cp "$SCRIPT_DIR/templates/PROJECT_CLAUDE_MINIMAL.md" "$PROJECT/CLAUDE.md"
    ok "CLAUDE.md template → $PROJECT/CLAUDE.md"
    warn "Edit $PROJECT/CLAUDE.md to describe your project"
else
    warn "CLAUDE.md already exists in project — skipped"
fi

# Create CHANGELOG.md if none exists
if [[ ! -f "$PROJECT/CHANGELOG.md" ]]; then
    DATE=$(date +%Y.%m.%d)
    printf "# Changelog\n\n## %s\n\n### What Changed\n- Project initialized\n\n### Technical Details\n-\n\n### Files Modified\n-\n" "$DATE" > "$PROJECT/CHANGELOG.md"
    ok "CHANGELOG.md created"
fi

# Create IDEAS.md if none exists
if [[ ! -f "$PROJECT/IDEAS.md" ]]; then
    printf "# Ideas\n\n## Claude's Ideashop\n\n<!-- Claude appends one idea per session here -->\n" > "$PROJECT/IDEAS.md"
    ok "IDEAS.md created"
fi

echo ""
echo "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo "${GREEN}  Done. Start Claude Code with: cd $PROJECT && claude${RESET}"
echo "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
