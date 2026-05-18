# Changelog — EDU/claude Bootstrap Repo

## 2026.05.18

**What Changed**
Security audit of the bootstrap sync pipeline revealed that neither `sync-bootstrap.sh` nor `up.sh` had any protection against accidentally publishing sensitive files to the public GitHub repo. Added four layers of defense: a `.gitignore`, per-file staging in the sync script, a pre-push secrets scan, and a project memory rule.

**Technical Details**
- `sync-bootstrap.sh` previously used `git add -A` — replaced with a `CHANGED_FILES` array that accumulates the exact relative path of each file as it is copied; the commit block now does `git add -- "${CHANGED_FILES[@]}"`, staging only what was actually synced
- `up.sh` gained a `check_for_secrets()` function that pipes `git diff --cached` through `grep -qiE` against a pattern list (`API_KEY`, `SECRET_KEY`, `ACCESS_TOKEN`, `PASSWORD=`, `PRIVATE_KEY`, PEM headers); aborts with `exit 1` and prints `git diff --cached --stat` if a match is found; called after staging and before every commit
- `up.sh` also now prints `git diff --cached --stat` before each commit so the user can see exactly what is going to GitHub
- `.gitignore` added covering: `settings.local.json`, `.env`, `.env.*`, `*.env`, `*.key`, `*.token`, `*.secret`, `*.pem`
- Project memory rule saved to `~/.claude/projects/-home-erik-EDU-claude/memory/project_pre_push_check.md`

**Files Modified**
- `.gitignore` (new)
- `sync-bootstrap.sh`
- `up.sh`

---

**What Changed (continued)**
Added `TODO.md` as a required project artifact alongside `CHANGELOG.md`. Encoded the rule in global `CLAUDE.md` and the `session-start` skill so it is enforced automatically. Created `TODO.md` for this repo. Assessed the `git add --all .` concern in `up.sh` and resolved it: `.gitignore` already excludes sensitive files, so broad staging in a general push script is acceptable — no code change needed.

**Technical Details**
- `CLAUDE.md` (both `~/.claude/` and repo copy): added `Every project must have a TODO.md; create one if absent` to Workflow; added `TODO.md` to the session-start read order
- `skills/session-start/SKILL.md`: added `TODO.md` as step 1 context file
- `TODO.md` created with two open items and a done list; the `up.sh` item was immediately closed after review — `.gitignore` resolves the concern without any code change
- Four additional best practices tips written covering: `CHANGED_FILES` array pattern, `git diff --cached --stat` before automated commits, `.gitignore` resolving broad staging concerns, TODO+CHANGELOG as session orientation tools

**Files Modified**
- `CLAUDE.md`
- `skills/session-start/SKILL.md`
- `TODO.md` (new)
- `BEST_PRACTICES.md`
