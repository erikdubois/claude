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
