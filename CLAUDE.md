# Global Claude Instructions

## Who I am

Erik — Arch Linux developer building Kiro, a full Arch-based Linux distro with its own package repo (`nemesis_repo`). Primary app: archlinux-tweak-tool (ATT), a large modular GTK4 Python system tool. Also: custom Linux ISOs, shell automation.

## This Repository

This folder (`~/EDU/claude`) is the **bootstrap source** for Claude Code config. It is not an application — it distributes config to `~/.claude/` and accepts changes back from it.

**Two-way sync:**

- repo → `~/.claude/` via [bootstrap.sh](bootstrap.sh) (manual, on new machines)
- `~/.claude/` → repo via [sync-bootstrap.sh](sync-bootstrap.sh) (auto-run by the SessionStart hook; auto-commits if anything changed)

**Common commands:**

| Command | What it does |
| --- | --- |
| `./bootstrap.sh` | Install repo contents to `~/.claude/` (pacman/AUR deps, hooks, skills, best_practices) |
| `./bootstrap.sh --project /path` | Bootstrap + seed `.claude/memory/`, `CLAUDE.md`, `CHANGELOG.md`, `IDEAS.md` in a project |
| `bash sync-bootstrap.sh` | Pull live `~/.claude/` state into repo; commits if anything differs |
| `./up.sh` | git pull → clean `__pycache__` → run optional `chaotic.sh`/`repo.sh` → add/commit/push |
| `./setup.sh` | Configure git identity + remote based on path (`EDU` → erikdubois, `KIRO` → kirodubes) |

**Editing gotchas:**

- [CLAUDE.md](CLAUDE.md) here *is* the file that gets installed globally — edits propagate to every machine that re-runs bootstrap.
- [settings.json](settings.json) here is a clean generic template; the live `~/.claude/settings.json` is **deliberately not synced back** ([sync-bootstrap.sh:20-22](sync-bootstrap.sh#L20-L22)) because it contains project-specific allow rules.
- [best_practices.md](best_practices.md) is auto-sanitized on sync (paths/usernames stripped via sed in [sync-bootstrap.sh:51-55](sync-bootstrap.sh#L51-L55)) — don't hand-edit identifiers back in.
- Hook scripts are installed to *two* locations by bootstrap (`~/.claude/hooks/` + flat `~/.claude/`) for backwards compat with the `settings.json` reference paths — [bootstrap.sh:117-120](bootstrap.sh#L117-L120).
- [memory/](memory/) holds the *universal* subset of feedback rules — only files that already exist here are refreshed from `~/.claude/projects/-home-erik/memory/` by sync; new rules must be added to this repo manually before they will start syncing.

## Environment

- OS: Arch Linux - dwm - chadwm - ohmychadwm
- Shell: fish (default), bash for scripts
- Languages: Python, bash, shell
- Editor: VSCode (Claude Code extension)
- Terminal: Alacritty

## Communication

- No emojis unless I ask
- Concise responses; no trailing "here's what I did" summaries
- Use markdown links for file references (clickable in VSCode), not backticks
- When I ask an exploratory question, give me a recommendation + the main tradeoff in 2–3 sentences — don't implement until I confirm

## Code style

- Remove inline comments that only restate a single line of code; keep comments that explain WHY
- Section dividers (`# ── Name ──────`) are kept in long functions (50+ lines) where they aid navigation; don't add them to short functions
- Docstrings follow PEP 257: public functions/methods/modules should have a one-line docstring; private functions (prefixed `_`) do not require them; never write multi-paragraph docstrings
- Don't add error handling for scenarios that can't happen
- Don't introduce abstractions beyond what the task requires
- Python: max line length 120; always run flake8 before considering any Python work done (don't ask permission, just run it)
- Bash scripts: always start with `set -euo pipefail`
- GTK4 callbacks: unused widget params named `_widget`, never `widget`
- Never use `subprocess.call()` from a GUI callback — always `Popen` in a daemon thread

## Git & commits

- User's confirmation to make a code change also authorizes: run flake8, fix any lint, commit, and push to origin in one shot — no second prompt needed
- Stage only the specific files changed — never `git add .` or `git add -A`
- Never amend a published commit; always create a new commit
- Never force-push

## Workflow

- Use plan mode before any change touching more than 2 files or with irreversible effects
- Every project must have a CHANGELOG.md; create one if absent
- After every session that changes code: update CHANGELOG.md without being asked
- Entry format — one entry per date (`YYYY.MM.DD`), consolidating all changes that day:
  - **What Changed** — what was done and why
  - **Technical Details** — how it was implemented, patterns used, non-obvious decisions
  - **Files Modified** — list of affected files
- Milestone-driven mindset: group related changes into logical milestones; flag when in-progress work is blocking a release

### Session start

Read in this order before doing any work: global CLAUDE.md → project CLAUDE.md → memory files → CHANGELOG.md

The `SessionStart` hook auto-runs `git pull` on the workspace and syncs `~/EDU/claude/` bootstrap from `~/.claude/`.

### Session end

When the user signals work is done for the day:

1. Update CHANGELOG.md with everything done that session
2. Update project CLAUDE.md (current state, next steps, any new patterns or decisions)
3. Update memory files if anything was learned about the user's preferences or the project
4. Sync memory to repo: `cp ~/.claude/projects/-home-erik-EDU-archlinux-tweak-tool-gtk4/memory/*.md .claude/memory/` then stage and commit `.claude/memory/`
5. Sync best practices to repo: `sed -e 's|linux-lqx|<package>|g' -e 's|/home/erik/\.bin/[^ ]*|~/.bin/<your-script>|g' -e 's|erikdubois/[^ ]*|<owner>/<repo>|g' ~/.claude/best_practices.md > BEST_PRACTICES.md` then stage and commit
6. If a distro was tested this session, update `DISTRO_TESTING.md` with the result
7. Append one creative idea to `IDEAS.md` (ATT projects) under the `## Claude's Ideashop` section — one concise idea with a rationale; never repeat a previous idea

Goal: next session starts with full context and zero re-explanation needed

## Confirmations

Ask before:

- Anything that affects shared state (PRs, issues, external services)
- Any edit: state exactly what you intend to change and why, then wait for approval before touching the file
- Files in a project's frozen list are read-only — never edit them without explicit instruction

## Objectives

- Help user to become a better AI/Claude user
- Help user to be efficient and cost effective
- Proactively flag token/cost saving opportunities mid-session without being asked — one sentence, inline, when you notice: batchable messages, a slash command that fits, a targeted grep vs full file read, unnecessary agent spawn, re-explaining context already in memory
- at end-of-day session close only: write two tips to ~/.claude/best_practices.md using the Write/Edit tool — never mid-session, always show them in chat too
- never repeat the tips — read best_practices.md first and check by concept, not just wording
