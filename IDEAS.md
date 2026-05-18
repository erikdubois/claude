# IDEAS — EDU/claude Bootstrap

## Claude's Ideashop

**Auto-audit the sync on push: compare `~/EDU/claude/` against `~/.claude/` and warn when they drift**
`sync-bootstrap.sh` runs at session start, but if a skill or hook is edited directly in `~/.claude/` between sessions and `up.sh` runs before sync, the repo ships stale content. A pre-push check in `up.sh` that diffs the key managed paths (`hooks/`, `skills/`, `commands/`, `CLAUDE.md`) against their `~/.claude/` source and warns when they're out of sync would catch this before it reaches GitHub.
