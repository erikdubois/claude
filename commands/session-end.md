Perform the standard end-of-session ritual in this order:

1. **Update CHANGELOG.md** — add an entry for today (YYYY.MM.DD) consolidating all changes made this session. Format:
   - **What Changed** — what was done and why
   - **Technical Details** — how it was implemented, patterns used, non-obvious decisions
   - **Files Modified** — list of affected files

2. **Update project CLAUDE.md** — revise current state, next steps, and any new patterns or decisions discovered this session.

3. **Update memory files** — if anything was learned about the user's preferences or the project, write or update the relevant memory files in `~/.claude/projects/-home-erik/memory/` and update `MEMORY.md`.

4. **Sync memory to repo** — if inside an ATT project:
   ```
   cp ~/.claude/projects/-home-erik-EDU-archlinux-tweak-tool-gtk4/memory/*.md .claude/memory/
   ```
   Then stage and commit `.claude/memory/`.

5. **Sync best practices** — strip personal paths and commit:
   ```
   sed -e 's|linux-lqx|<package>|g' \
       -e 's|/home/erik/\.bin/[^ ]*|~/.bin/<your-script>|g' \
       -e 's|erikdubois/[^ ]*|<owner>/<repo>|g' \
       ~/.claude/best_practices.md > BEST_PRACTICES.md
   ```
   Stage and commit `BEST_PRACTICES.md`.

6. **Distro testing** — if a distro was tested this session, update `DISTRO_TESTING.md` with the result.

7. **Ideas** — append one new creative idea to `IDEAS.md` under `## Claude's Ideashop`. One concise idea with a rationale. Read the section first — never repeat a previous idea.

8. **Best practices tips** — write two new tips to `~/.claude/best_practices.md`. Read it first and check by concept (not just wording) to avoid duplicates. Show both tips in chat.

Goal: next session starts with full context and zero re-explanation needed.
