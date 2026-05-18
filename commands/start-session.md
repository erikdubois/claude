Perform the standard session-start sequence in this order:

1. Read `~/.claude/CLAUDE.md` (global instructions)
2. Read the project's `CLAUDE.md` if one exists in the current working directory
3. Read all memory files listed in `~/.claude/projects/-home-erik/memory/MEMORY.md` (and any project-specific memory index at `.claude/memory/MEMORY.md` if it exists)
4. Read `CHANGELOG.md` in the current working directory if it exists

After reading, give a one-paragraph status summary:
- What project this is and its current state (from CHANGELOG)
- Any in-progress work or blockers noted in memory or CLAUDE.md
- What the user was likely working on last session

Do not start any implementation work — just orient and report.
