# Tips Quick Reference

Extracted and categorized from `best_practices.md` (295 tips, accumulated from 100+ real sessions).
Full tips with code examples are in [best_practices.md](best_practices.md).

---

## Claude Code — How to Use Efficiently

### Prompting
- Prefix questions with `"exploratory:"` to get a recommendation without implementation
- Prefix with `"report only, don't change anything"` for pure analysis
- Say `"think hard"` to trigger extended reasoning before Claude answers
- Scope prompts to one file / one widget / one function at a time — precision beats breadth
- When a fix doesn't work, point Claude to a working example in the same codebase
- Describe the observable **symptom**, not the assumed cause — shortest path to fix
- Name the pattern you want to match, not just the problem — Claude implements faster
- One-word answers work — `"y"` is a valid approval that saves tokens
- Say `"just for me"` to get leaner, more direct code
- Paste the full Python traceback — the filename:line in it pinpoints the fix in seconds
- Paste a script and ask `"what does this do?"` before asking for changes — intent mismatches surface instantly

### Context & Files
- Use `#` in Claude Code terminal to open file picker and inject a path directly
- Use `@filename` in your prompt to pin a file into context without opening it in the IDE
- Highlight code in VSCode before sending a request — Claude sees your selection automatically
- `paste filepath:linenum` in chat to point Claude at an exact line without preamble
- Batch independent reads + questions into one message to parallelize work
- Ask `"where is X used?"` before opening files — skip the grep yourself
- Use `git log + diff` to brief Claude at session start instead of re-explaining context

### Claude Code Commands (slash commands)
- `/cost` — track session cost and context usage mid-session
- `/compact` — free context window space; use when switching tasks or after loading many large files
- `/clear` — use between unrelated tasks to prevent context bleed
- `/review` — code review of current branch or a specific file
- `/review <module>` — scope to one feature area
- `/simplify` — catch quality issues: reuse, efficiency, clarity
- `/security-review` — catch permission and injection bugs before commit
- `/ultrareview` — independent multi-agent cloud review; use before milestone commits
- `/fewer-permission-prompts` — build an allowlist from your session's repeated prompts
- `/init` — auto-load architecture context for any repo
- `/help` — see every available skill and slash command
- `/fast` — toggle faster output on Claude Opus
- `/model haiku` — switch to Haiku for trivial mechanical edits; save Sonnet tokens
- `Escape` — cancel Claude's current response mid-generation
- `! <command>` — run a shell command and inject its output directly into conversation

### Agents & Subagents
- Use `subagent_type: "Explore"` for codebase analysis — keeps your main context clean
- Use `subagent_type: "Plan"` for full implementation plan before writing any code
- Pass `run_in_background: true` on independent Agent calls to run them in parallel
- Pass `model: "opus"` on individual Agent calls for only the hard sub-task
- Pass `isolation: "worktree"` to experiment on a throwaway branch
- Run `grep -rn "pattern" *.py` yourself for simple lookups — don't spawn an agent for it
- Write a `"next step"` note in chat before `/compact` — it's the one thing that survives compression

### Cost Management
- Use `/model haiku` for trivial mechanical edits
- Use `claude --continue` to resume the last session without re-explaining context
- Use `claude --print` for quick one-off script audits
- Switch to `/model haiku` for fast lookups, Sonnet for reasoning, Opus for architecture
- Scope reads with `offset + limit` to avoid burning context on large files
- Use `/compact` when you've loaded many large files
- Ask multiple independent questions in one message for parallel reads

---

## Session Management

### Starting a Session
- Read: global CLAUDE.md → project CLAUDE.md → memory files → CHANGELOG.md
- `git pull` before any work — never assume working tree is current
- `git status` — confirm clean tree; `git log --oneline -5` — see where you left off
- Ask `"what do you remember about me?"` at session start to verify memory loaded correctly
- Ask `"is this already done?"` before implementing — stale TODOs are common

### During a Session
- Use plan mode before any change touching more than 2 files or with irreversible effects
- Skip plan mode for single-line, fully reversible edits — just state and wait for `"y"`
- Chain `/review` with `/simplify` for a two-pass improvement cycle
- Use `"plan it out — then summarize and ask to proceed"` to make Claude a reviewer first
- When you find a pattern bug in one item, immediately ask `"are there similar cases?"`
- Ask Claude to identify the shared root cause across a list of bugs before fixing any one

### Ending a Session
1. Update `CHANGELOG.md` (date + What Changed / Technical Details / Files Modified)
2. Update project `CLAUDE.md` (Recent Work, current state, next steps)
3. Update memory files with anything learned
4. Sync memory to repo: `cp ~/.claude/projects/<path>/memory/*.md .claude/memory/`
5. Sync best practices: `cp ~/.claude/best_practices.md best_practices.md`
6. Update `TODO.md` — always part of session end
7. Append one idea to `IDEAS.md` under `## Claude's Ideashop` (never repeat)
8. `git add` specific files only (never `git add .`)
9. Commit and push

### CLAUDE.md as a Tool
- CLAUDE.md rules are re-read every session — encode permanent decisions here
- Use both global and project CLAUDE.md — project overrides global
- Treat CLAUDE.md as executable spec, not documentation
- Pin frequently-needed constants to CLAUDE.md to eliminate read tool calls
- Write `## Key config notes` sections for non-obvious values
- Put shareable links in `## Reference links` — not just in the file they describe

---

## Git Workflow

- `git pull` before every task — no exceptions; other Claude tabs may have pushed
- Stage only specific files — never `git add .` or `git add -A`
- Never amend published commits — create new ones
- Never force-push
- Never create git tags
- Use `gh` CLI for PR-native workflows (install separately: `sudo pacman -S github-cli`)
- `git stash` doesn't sync to remote — work stashed on one machine is invisible on another
- Use `git pull --rebase --autostash` to handle unstaged changes automatically
- Name your stashes: `git stash push -m "name"` to find them later
- Use `git diff HEAD~N..HEAD -- <file>` to audit what changed across a block of sessions
- Use `/review` before committing multi-file changes

---

## Python Code Quality

### Flake8
- Always run flake8 before considering Python work done — auto-fix all violations, no asking
- Run `flake8 --select=F401` to isolate unused import cleanup
- In utility modules, always grep for actual usage before removing F401-flagged imports
- Run `vulture usr/share/<app>/ --min-confidence 80` periodically to find dead code flake8 misses

### Code Style
- Max line length: 120
- `snake_case` for variables/functions, `PascalCase` for classes
- Public functions: one-line docstring (PEP 257); private (`_`-prefix): none required
- Section dividers (`# ── Name ──`) only in functions 50+ lines
- When doing a `replace_all` rename, rename longer names before shorter substring ones
- Replace `idx = [0]` closure mutation with `nonlocal` in Python 3

### Architecture
- Before implementing new functionality, grep the existing codebase — it may already be there
- When a helper is reused by a second module, move it to the shared utility module immediately
- Never import sideways between feature modules — only import upward into shared utilities
- Two writes to the same config file in one handler is a red flag — one is likely stale
- Cache config files that are read many times; invalidate only on write
- Warm a per-session cache in one bulk call rather than caching lazily on first access
- Read dead code before deleting it — it may be hiding a real bug above it
- Trust tested commands over theoretical solutions

### Imports & Subprocess
- `python3 -c "import module; print('✓')"` to validate imports without launching the full app
- Never `subprocess.call()` for GUI terminal launches — always `Popen` in a daemon thread
- Any post-operation helper must return a `Popen` — not run subprocess inline — so callers can `.wait()`
- Always capture and check `Popen.wait()`'s return code — discarding silently hides failures
- Replace `threading.Event().wait(N)` with `process.wait()` — a fixed sleep never knows when terminal closed

---

## GTK4 Patterns

- Unused GTK signal params: always `_widget`, never `widget`
- `&` in `set_markup()` → `&amp;` always — or the label silently renders empty
- Widget names: never `hbox1`, `vbox2` — always descriptive (`hbox_current_boot`)
- Rename all occurrences (construction + append + `self.*`) together, never partially
- To reorder page sections, only move the `append()` calls — widget construction order doesn't matter
- Guard WIP widget **appends** (not construction) with `if fn.DEV:` — widget must still be built
- Never mention `--dev` in UI text, logs, or conversation — hidden means hidden
- Section headers: `label.set_markup("<b>Section Name</b>")` — always `set_markup`, never `set_text`
- `GTK_DEBUG=interactive python3 app.py` — inspect any live widget without reading source
- `Gtk.GestureClick` with `set_button(3)` works on any widget for right-click handling
- `GLib.idle_add` with `return False` runs callback exactly once after main loop starts
- Daemon threads can't show GTK dialogs directly — use `GLib.idle_add` to hand back to main loop
- `set_size_request` in GTK4 sets a minimum, not a maximum — pair with `set_vexpand(False)`
- `Gtk.DropDown` model refresh: splice-clear then re-populate — toggling visibility alone is insufficient
- Use `close-request` + `get_width()`/`get_height()` to persist window size — not `notify::default-width`
- `Gtk.Picture` alternative: CSS-colored box when you need truly fixed-height bars
- Use `notify::position` on `Gtk.Paned` to persist divider position — no "on close" handler needed
- Pre-load all hover-state assets at startup — never decode from disk inside a mouse event
- Greyed-out buttons must have a tooltip — never leave unexplained disabled UI

### Logging Pattern (two-street rule)
- `log_*` calls for ALL user-visible actions — present even without `--debug`
- `debug_print` only for source/target path detail (requires `--debug` flag)
- Demote high-frequency internal status lines from `log_*` to `debug_print`
- Audit both success AND failure paths for `log_*` + notification

### Terminal Launch Pattern
- `alacritty` launches: use `read -p "Press Enter..."` at end of script — NOT `--hold` with `read -p` (pick one)
- Post-terminal refresh: always use `wait_and_refresh` in daemon thread — never fixed `GLib.timeout_add`
- Logic function must return the `Popen` object so caller can `.wait()`
- Always call `fn.invalidate_pkg_cache()` in every `wait_and_refresh` closure after install/remove

---

## Bash Scripting

### Script Standards
- Always start with `set -euo pipefail`
- Define color codes at top with `tput`: `RESET`, `CYAN`, `GREEN`, `RED`, `YELLOW`
- Define `separator`, `header`, `success`, `info`, `warn`, `error` helper functions
- Never bare `echo` for output — use the helper functions
- Use `trap 'echo ""; read -p "Press Enter to close..."' EXIT` — terminal stays open even on early abort
- `bash -n script.sh` — syntax-check without executing
- Add `set -x` temporarily when an error trap fires with no clear cause
- Always quote `$HOME` — `$HOME"/path"` is a quoting antipattern
- Always add `2>&1` when redirecting diagnostic command output to `/dev/null`
- Replace `if [ $? -ne 0 ]` with `if ! command` for cleaner error guards
- `{ cmd1 && cmd2; } || cmd3` when you need OR against a compound AND

### Package Management (Arch)
- `pacman -Q <name>` over `pacman -Qo <path>` for package detection in elevated processes
- Always check for `-git` AUR variants when guarding UI on package presence
- Verify package repo membership before writing install scripts: `pacman -Si <pkg>`
- Never mix official-repo and AUR packages in one `pacman -S` call
- Use `sudo -H` when running AUR helpers as real user — without it, HOME stays root's home
- `sha256sums=('SKIP')` for `git+` sources in PKGBUILD — checksums on git repos are always invalid

### Environment & Sudo
- When launching GUI app as real user from root: always override HOME explicitly — `sudo -E` inherits root's HOME
- Pattern: `sudo -E -u <user> env HOME=/home/<user> command`
- On Plasma/Wayland: GUI apps spawned from pkexec/sudo need `WAYLAND_DISPLAY` injected
- Use `/proc/<pid>/environ` to recover stripped env vars when running as root
- Prefer `XDG_SESSION_TYPE` over `loginctl` parsing for session detection

---

## Debugging

- `journalctl -b | grep <service>` — filter boot log to service events
- `dmesg --color=always | less -R` — colorized severity filtering
- Filter `dmesg` by log level to skip informational noise
- `python3 -c "import module; print('✓')"` — validate imports without full app launch
- Add `fn.debug_print(f"state: {variable}")` at callback entry to confirm what callback receives
- Before fixing a widget that `"does nothing"`, check whether its container is ever appended
- The root cause of `"button has no effect on the label"` is almost always scope, not logic
- When `"fix"` button leaves warning visible, check if fix runs ALL checks that status verifies
- Read `/proc/<pid>/environ` to see actual environment a process inherited
- Fake a desktop environment with `XDG_CURRENT_DESKTOP=X` to test conditional UI without switching DEs
- VirtualBox is the wrong environment for bootloader/initramfs integration tests

---

## Code Reviews

- `/review` — structured review of current branch or staged changes
- `/review <file>` — scope to one file for precise findings
- `/simplify` — after edits, catch quality issues across reuse/quality/efficiency
- `/security-review` — before any script touching `chmod`, `chown`, or `/etc`
- `/ultrareview` — independent multi-agent review; before milestone commits, cross-repo changes
- Chain: `/review` → `/simplify` for two-pass improvement
- Run `/review` on a bash script after reformatting — rewrites silently change behavior
- Read the code before acting on a multi-agent review finding — half the flags are false positives

---

## Working with Memory & CLAUDE.md

### Memory System
- Memory files: `~/.claude/projects/<encoded-path>/memory/` (auto-loaded each session)
- Project memory: `.claude/memory/` inside the repo (synced at session end)
- Copy project memory to repo at session end so it travels with the code
- `MEMORY.md` is the index — Claude loads it first to determine which files to read

### What to Put in Memory
- User preferences: communication style, tech level, workflow habits
- Feedback: rules derived from corrections (corrections + confirmations)
- Project facts: decisions, constraints, current state
- References: where to find external docs, dashboards, trackers

### What NOT to Put in Memory
- Code patterns, architecture, file paths (derive from code)
- Git history (use `git log`)
- Debugging solutions or fix recipes (the fix is in the code)
- Ephemeral task state (use tasks/plans instead)
