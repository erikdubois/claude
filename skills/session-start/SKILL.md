---
name: session-start
description: Run the session-start checklist — read context files, git pull, sync bootstrap, report milestone and task
allowed-tools: "Bash Read"
---

Run the session-start checklist for the current project. Execute all steps silently and report findings in one block at the end.

## Checklist

### 1. Read context (in order)
- `~/.claude/CLAUDE.md` — global instructions
- Project `CLAUDE.md` — project instructions, current state, next steps
- `.claude/memory/MEMORY.md` — memory index; read any memory files relevant to today's work
- `CHANGELOG.md` — what was done last session
- `TODO.md` — current open tasks and pending work

### 2. Git status
```bash
git pull
git status --short
git log --oneline -5
```
If `git pull` pulled new commits, summarise what changed in one line.
If the working tree is dirty, list the modified files.

### 3. Sync bootstrap
```bash
bash ~/EDU/claude/sync-bootstrap.sh
```
Report whether anything was synced.

### 4. Report (print this block)

```
Session start — <project name>

Last session: <one-line summary from CHANGELOG>
Current milestone: <from CLAUDE.md project plan>
Next task: <first unchecked item or stated next step>

Git: <"clean" | list of modified files>
<"Up to date" | "Pulled N commits: <summary>">
Bootstrap: <"synced and committed" | "no changes">

Ready.
```

Keep the report tight — no extra explanation. The user will direct what to work on next.
