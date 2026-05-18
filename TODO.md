# TODO — EDU/claude Bootstrap

## Open

- [ ] Verify skills in `~/EDU/claude/skills/` are also present in `~/.claude/skills/` — sync currently goes one way only (from `~/.claude/` to repo); skills that exist only in the repo won't be loaded by the harness
- [x] Tighten `up.sh` staging: `git add --all .` is acceptable — `.gitignore` excludes sensitive files; `up.sh` is a general push script and must stage all manually edited files

## Done

- [x] Add `.gitignore` covering `settings.local.json`, `.env*`, `*.key`, `*.token`, `*.pem`
- [x] Replace `git add -A` in `sync-bootstrap.sh` with per-file `CHANGED_FILES` tracking
- [x] Add `check_for_secrets()` pre-push grep to `up.sh`
- [x] Add `git diff --cached --stat` display before every automated commit in `up.sh`
- [x] Add project memory rule: always check staged content before pushing
- [x] Require `TODO.md` in all projects; add to session-start read order
