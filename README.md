# Claude Code — Bootstrap Folder

This folder contains everything needed to get Claude Code working efficiently on a new machine, with all accumulated preferences, feedback, and best practices already loaded.

Generated: 2026-05-17. Source projects: archlinux-tweak-tool-gtk4, alacritty-tweak-tool, linux-kiro-lqx.

---

## What's Here

```
claude/
├── README.md                   ← you are here
├── CLAUDE.md                   ← global Claude instructions (copy to ~/.claude/CLAUDE.md)
├── settings.json               ← Claude Code settings with hooks (copy to ~/.claude/settings.json)
├── settings.local.json         ← local permissions template (copy to ~/.claude/settings.local.json)
├── best_practices.md           ← 295 tips accumulated from real coding sessions
├── TIPS_QUICKREF.md            ← all tips categorized: prompting, git, GTK4, bash, debugging
├── bootstrap.sh                ← installs everything to ~/.claude/ in one shot
├── hooks/
│   ├── flake8-hook.sh          ← auto-runs flake8 after every Python file edit (PostToolUse)
│   ├── statusline.sh           ← status bar: model / project / context% / cost
│   └── session-start.sh       ← auto git pull at session start (SessionStart hook)
├── skills/
│   ├── session-start/SKILL.md ← /session-start — reads context, git pull, reports milestone
│   └── session-end/SKILL.md   ← /session-end — full EOD checklist: CHANGELOG, memory, tips, commit
├── memory/                     ← universal memory files (copy to .claude/memory/ in project)
│   ├── MEMORY.md               ← memory index (required by Claude)
│   └── feedback_*.md           ← accumulated feedback rules from 100+ sessions
└── templates/
    ├── PROJECT_CLAUDE_MINIMAL.md      ← blank project CLAUDE.md with all required sections
    └── PROJECT_CLAUDE_GTK4_PYTHON.md  ← full GTK4 Python project template (ATT pattern)
```

---

## Bootstrap a New Machine

### Step 1 — Install Claude Code

```bash
npm install -g @anthropic/claude-code
```

### Step 2 — Copy config files

```bash
# Global Claude instructions
cp /path/to/this/folder/CLAUDE.md ~/.claude/CLAUDE.md

# Settings (hooks + statusline)
cp /path/to/this/folder/settings.json ~/.claude/settings.json

# Optional: local permissions override
cp /path/to/this/folder/settings.local.json ~/.claude/settings.local.json

# Hook scripts (must be executable)
cp /path/to/this/folder/hooks/flake8-hook.sh ~/.claude/flake8-hook.sh
cp /path/to/this/folder/hooks/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/flake8-hook.sh ~/.claude/statusline.sh

# Best practices
cp /path/to/this/folder/best_practices.md ~/.claude/best_practices.md
```

### Step 3 — Set up a new project

1. Create the project's memory directory:
   ```bash
   mkdir -p /path/to/project/.claude/memory
   ```

2. Copy the memory files:
   ```bash
   cp /path/to/this/folder/memory/*.md /path/to/project/.claude/memory/
   ```

3. Copy and adapt the right CLAUDE.md template:
   ```bash
   cp /path/to/this/folder/templates/PROJECT_CLAUDE_MINIMAL.md /path/to/project/CLAUDE.md
   # Edit it to match the new project
   ```

4. Start Claude Code in the project directory:
   ```bash
   cd /path/to/project
   claude
   ```

---

## How the Hooks Work

### session-start.sh (SessionStart hook)
Runs automatically when Claude opens a session. Checks if the workspace is a git repo and runs `git pull`. Silent when already up to date; surfaces the pull summary only when commits were fetched.

### flake8-hook.sh (PostToolUse hook)
Runs automatically after every `Edit` or `Write` tool call on a `.py` file. If flake8 finds issues, it feeds them back to Claude as a follow-up instruction to fix them — no manual intervention needed. Configured to ignore E402, W503, W504, E128, E203.

### statusline.sh
Displays in the Claude Code status bar (bottom of terminal):
```
[claude-sonnet-4-6] my-project | context: 42% used | cost: $0.0312
```
Reads model name, current directory, context usage %, and session cost from Claude's status JSON.

## Skills (Slash Commands)

Skills live in `~/.claude/skills/` (global) or `.claude/skills/` (project). Invoke with `/skill-name`.

### /session-start
Runs the startup checklist: reads all context files (CLAUDE.md, memory, CHANGELOG), does `git pull`, reports current milestone and next task in one compact block.

### /session-end
Runs the full EOD checklist automatically:
1. Updates CHANGELOG.md
2. Updates project CLAUDE.md (Recent Work, Next Steps)
3. Updates TODO.md
4. Writes/updates memory files
5. Syncs memory to repo
6. Syncs best_practices.md
7. Appends one idea to IDEAS.md
8. Writes two new tips to best_practices.md
9. Commits and pushes all changes

---

## How the Memory System Works

Memory files live in `~/.claude/projects/<encoded-path>/memory/` for global memory, or in `.claude/memory/` inside the project repo for project-specific memory.

At the start of each session Claude reads:
1. `~/.claude/CLAUDE.md` — global instructions
2. `CLAUDE.md` in the project root — project instructions
3. Memory files — accumulated feedback and project state
4. `CHANGELOG.md` — recent work history

**Global memory** (in `~/.claude/projects/-home-erik/memory/`) applies to all projects.
**Project memory** (in `.claude/memory/` inside the repo) applies only to that project.

### Syncing memory back to the repo
At session end, sync memory so it travels with the code:
```bash
cp ~/.claude/projects/<encoded-project-path>/memory/*.md .claude/memory/
git add .claude/memory/
git commit -m "chore: sync claude memory"
```

---

## Key Rules (quick reference)

These are the most important rules Claude follows in every session. Full details in the memory files.

| Rule                                                            | File                                     |
|-----------------------------------------------------------------|------------------------------------------|
| Never edit without explicit confirmation                        | `feedback_no_changes_without_consent.md` |
| Re-asking = implicit confirm, just implement                    | `feedback_confirm_re_ask.md`             |
| After "go ahead", no mid-plan check-ins                         | `feedback_just_go_ahead.md`              |
| git pull before every task, Claude owns all git ops             | `feedback_git_management.md`             |
| Confirm → Claude edits, lints, commits, pushes                  | `feedback_user_commits.md`               |
| flake8: fix all violations automatically, no asking             | `feedback_flake8_auto_fix.md`            |
| Never use `gh` CLI (not installed on Arch)                      | `feedback_no_gh_cli.md`                  |
| Never create git tags                                           | `git_tag_never.md`                       |
| Unused GTK params: `_widget`, never `widget`                    | `feedback_widget_underscore.md`          |
| No numbered widget names (hbox1, vbox2, etc.)                   | `feedback_widget_naming.md`              |
| & in GTK markup → `&amp;` always                                | `feedback_gtk_markup_ampersand.md`       |
| Never `subprocess.call()` for terminal launches                 | `feedback_no_blocking_subprocess.md`     |
| Two-street logging: log_* always, debug_print only with --debug | `feedback_two_street_logging.md`         |
| Session end must include TODO.md update                         | `feedback_session_end_todo.md`           |
| End-of-session tips: always read best_practices.md first        | `feedback_no_repeat_tips.md`             |

---

## Session End Checklist (every project)

1. Update `CHANGELOG.md` (date + What Changed / Technical Details / Files Modified)
2. Update project `CLAUDE.md` (Recent Work, current state, next steps)
3. Sync memory: `cp ~/.claude/projects/<path>/memory/*.md .claude/memory/`
4. Sync best practices: `cp ~/.claude/best_practices.md /path/to/project/best_practices.md`
5. Stage specific files only (never `git add .`)
6. Commit and push
7. Append one idea to `IDEAS.md` under `## Claude's Ideashop`

---

## File Sources

| File                   | Source                                                             |
|------------------------|--------------------------------------------------------------------|
| `CLAUDE.md`            | `~/.claude/CLAUDE.md`                                              |
| `settings.json`        | `~/.claude/settings.json` (cleaned)                                |
| `settings.local.json`  | `~/.claude/settings.local.json`                                    |
| `hooks/flake8-hook.sh` | `~/.claude/flake8-hook.sh`                                         |
| `hooks/statusline.sh`  | `~/.claude/statusline.sh`                                          |
| `best_practices.md`    | `~/.claude/best_practices.md` (paths sanitized)                    |
| `memory/*.md`          | `EDU/archlinux-tweak-tool-gtk4/.claude/memory/` (universal subset) |
| `templates/`           | hand-distilled from ATT + alacritty-tweak-tool CLAUDE.md files     |
