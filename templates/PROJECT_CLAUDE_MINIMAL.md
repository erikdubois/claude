# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Project Overview

<!-- One paragraph: what the project does, who it's for, what problem it solves -->

- **Language**: Python 3.x / Bash / other
- **Entry Point**: `path/to/main.py`
- **Runs as**: normal user / root (via sudo/pkexec)

## Requirements

<!-- List runtime dependencies -->

## Architecture

```
project/
├── main.py          # Entry point
├── functions.py     # Shared utilities
└── ...
```

## Development Patterns

### Logging

<!-- Describe the logging API — never use print() -->

### Code Style
- `flake8` must pass (max line 120)
- `snake_case` for variables/functions, `PascalCase` for classes
- GTK4 callbacks: unused params named `_widget`
- No numbered widget names (`hbox1`, `vbox2`) — use descriptive names

### Frozen Files
<!-- List files that must never be edited without explicit instruction -->

## Running the Application

```bash
# Normal run
python3 main.py

# With debug output
python3 main.py --debug
```

## Workflow

### Session Start
1. `git pull`
2. `git status` — confirm clean tree
3. `git log --oneline -5` — see where we left off
4. If touching more than 2 files → use plan mode first

### Session End
1. Run flake8, fix any issues
2. Run the app and confirm it still launches
3. Update `CHANGELOG.md`
4. Update this `CLAUDE.md` (Recent Work section)
5. Sync memory: `cp ~/.claude/projects/<encoded-path>/memory/*.md .claude/memory/`
6. Sync best practices: `cp ~/.claude/best_practices.md best_practices.md`
7. Append one idea to `IDEAS.md` under `## Claude's Ideashop`
8. `git add` specific files, commit, push

### Confirmations
State exactly what you intend to change and why, then wait for approval before touching any file.

## Recent Work

<!-- Most recent entries first — format: YYYY.MM.DD — description -->
