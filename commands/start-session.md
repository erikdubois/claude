Perform the standard session-start sequence in this order:

1. Read `~/.claude/CLAUDE.md` (global instructions)
2. Read `~/.claude/GLOSSARY.md` (shorthand → canonical path map)
3. Refresh and read the home index:
   - Read the `Generated:` date in the header of `~/.claude/home_index.md`
   - If that date is not today's date (or the file is missing), run `bash ~/.bin/refresh-home-index.sh` to regenerate it, then read it
   - If today's date matches, just read it
4. Read the project's `CLAUDE.md` if one exists in the current working directory
5. Read all memory files listed in `~/.claude/projects/-home-erik/memory/MEMORY.md` (and any project-specific memory index at `.claude/memory/MEMORY.md` if it exists)
6. Read `CHANGELOG.md` in the current working directory if it exists

After reading, give a one-paragraph status summary:
- What project this is and its current state (from CHANGELOG)
- Any in-progress work or blockers noted in memory or CLAUDE.md
- What the user was likely working on last session

Do not start any implementation work — just orient and report.

## Name resolution (use throughout the session, not just at start)

When the user refers to a project, script, or directory by name:
1. Look up the term in `~/.claude/GLOSSARY.md` first (cheapest — already loaded).
2. If not in the glossary, look in `~/.claude/home_index.md` (also loaded).
3. Only if both miss, fall back to a filesystem search.

When you resolve a shorthand to a path, echo the path back to the user **before** acting on a destructive or hard-to-reverse operation.
