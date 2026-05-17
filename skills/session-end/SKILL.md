---
name: session-end
description: Run the complete end-of-session checklist — CHANGELOG, memory sync, best_practices, TODO, IDEAS, commit, push
allowed-tools: "Bash Edit Write Read"
---

Run the full end-of-session checklist for the current project, in this exact order. Do not skip steps. Do not ask permission between steps — execute all of them.

## Checklist

### 1. CHANGELOG.md
- Read the current CHANGELOG.md
- Add a new entry for today's date (format: `YYYY.MM.DD`) at the top
- Entry must have three sections: **What Changed**, **Technical Details**, **Files Modified**
- Consolidate everything done this session into one entry for today
- If today's date already has an entry, merge into it

### 2. Project CLAUDE.md
- Read the project CLAUDE.md
- Update the **Recent Work** section with a one-line summary of what was done today (newest first)
- Update **Current State** or **Next Steps** if the project state changed

### 3. TODO.md
- Read TODO.md if it exists
- Tick off any items completed this session
- Add any new TODOs discovered during the session

### 4. Memory files
- Identify anything learned this session about the user's preferences, workflow, or the project that is not already in a memory file
- Write new memory files or update existing ones in `~/.claude/projects/<encoded-path>/memory/`
- Update `MEMORY.md` index if new files were added

### 5. Sync memory to repo
```bash
cp ~/.claude/projects/<encoded-path>/memory/*.md .claude/memory/
```
Stage and include `.claude/memory/` in the commit.

### 6. Sync best_practices.md
```bash
cp ~/.claude/best_practices.md best_practices.md
```
Stage `best_practices.md` for the commit.

### 7. IDEAS.md
- Read `IDEAS.md` and the `## Claude's Ideashop` section
- Append ONE new creative idea that was not previously listed
- Idea format: one sentence describing the idea + one sentence rationale
- Never repeat a previous idea — check by concept, not just wording

### 8. Tips (write to best_practices.md)
- Read `~/.claude/best_practices.md`
- Write TWO new tips at the top of the file, under today's session header
- Each tip: a bold one-line title + 2–4 lines of explanation
- Check by concept first — never repeat an existing tip even in different words
- Show both tips in chat after writing them

### 9. Commit and push
- `git add` only the specific files changed (never `git add .`)
- Commit with a clear message summarizing the session
- `git push origin`

### 10. Report
Print a one-line summary: what was done, what is next.
