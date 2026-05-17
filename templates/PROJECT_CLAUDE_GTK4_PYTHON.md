# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Project Overview

<!-- Name and purpose of the GTK4 Python application -->

- **Language**: Python 3.8+
- **GUI Framework**: GTK4 (4.6+)
- **Entry Point**: `usr/share/<app-name>/<app-name>.py`
- **Desktop Launcher**: `usr/share/applications/<app-name>.desktop`
- **Runs as**: <!-- normal user / root via pkexec -->

## Requirements

**Runtime:**
- Python 3.8+
- GTK4 libraries (4.6+) + GObject Introspection (gi)
- Standard library: os, sys, subprocess, threading, time, shutil, json

## Architecture

```
usr/share/<app-name>/
├── <app-name>.py          # Main entry point, GTK Application
├── functions.py           # Central utility module (logging, subprocess, helpers)
├── gui.py                 # Main GUI container — imports all *_gui modules
├── <feature>.py           # Business logic per feature
├── <feature>_gui.py       # GTK interface per feature
└── images/                # Application assets
```

### Module Pattern
Every feature has two files: `<feature>.py` (logic) and `<feature>_gui.py` (GTK widgets).
Callbacks go in `<feature>_gui.py` unless they grow large, then isolate in `<feature>_callbacks.py`.

## Developer Objectives

1. **Fast Loading** — lazy-load heavy modules at startup
2. **Modular** — strict feature.py + feature_gui.py separation
3. **Dual Logging** — in-app notifications + console output for all operations
4. **Safe Operations** — use popup terminal (Alacritty) for installs/removals
5. **Non-Invasive** — respect user system state; avoid unwanted modifications
6. **Transparency** — show the user what is happening to their system

## Development Patterns

### Logging & Output

All output uses `functions.py` logging (never `print()`):

```python
import functions as fn

fn.debug_print(message)              # --debug flag only
fn.log_section("Major Header")       # Green section header
fn.log_subsection("Minor Header")    # Cyan subsection
fn.log_info("Informational")         # Blue info
fn.log_success("Success message")    # Green success
fn.log_warn("Warning message")       # Yellow warning
fn.log_error("Error message")        # Red error
```

**Two-street rule:** `log_*` calls must be present for ALL user-visible actions even without `--debug`. `debug_print` is only for source/target path detail.

### GTK4 Callbacks

```python
def on_button_click(self, _widget):  # _widget always, even if unused
    fn.log_success("Button clicked")
```

### Markup & Special Characters

```python
label.set_markup("Set <b>&amp;</b> configure")  # & → &amp; always
```

### Terminal Actions — wait_and_refresh Pattern

```python
# In logic module — always return the Popen object
def install_something(self):
    fn.log_subsection("Installing something...")
    return fn.subprocess.Popen(
        ["alacritty", "-e", "bash", "-c", "sudo pacman -S something; read -p 'Press enter...'"],
        stdout=fn.subprocess.PIPE, stderr=fn.subprocess.PIPE,
    )

# In GUI — wait for terminal, then refresh
def wait_and_refresh(process):
    if process is None:
        fn.GLib.idle_add(refresh_labels)
        return
    process.wait()
    fn.GLib.idle_add(refresh_labels)

btn.connect("clicked",
    lambda w: fn.threading.Thread(
        target=wait_and_refresh, args=(install_something(self),), daemon=True
    ).start()
)
```

### Dev Mode (WIP features)

Guard WIP widget **appends** (not construction) with `if fn.DEV:`:
```python
if fn.DEV:
    vbox.append(hbox_experimental)
```
Never mention `--dev` in UI text, logs, or conversation.

### Widget Naming

- **Never** use numbered names (`hbox1`, `vbox2`, `hbox3`)
- **Always** descriptive: `hbox_current_boot`, `vbox_pacman_log`
- Rename all occurrences (construction + append + self.*) together

### Section Headers in Pages

```python
label.set_markup("<b>Section Name</b>")  # always set_markup for section headers
```

### ATT Script Standard (for bash scripts)

Every bash script must:
```bash
set -euo pipefail
RESET=$(tput sgr0); CYAN=$(tput setaf 6); GREEN=$(tput setaf 2)
RED=$(tput setaf 1); YELLOW=$(tput setaf 3)
separator() { echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }
header()    { separator; echo "${CYAN}  $1${RESET}"; separator; }
success()   { echo "${GREEN}  ✓ $1${RESET}"; }
info()      { echo "  $1"; }
warn()      { echo "${YELLOW}  ⚠ $1${RESET}"; }
error()     { echo "${RED}  ✗ $1${RESET}"; }
```

## Running the Application

```bash
# Requires root for system operations
sudo python3 usr/share/<app-name>/<app-name>.py

# With debug output
sudo python3 usr/share/<app-name>/<app-name>.py --debug

# Dev mode (shows WIP UI)
sudo python3 usr/share/<app-name>/<app-name>.py --dev
```

## Frozen Files

Never edit these without an explicit file-specific instruction:
- `usr/bin/<app-name>` (launcher)
- `setup.sh` (installer)

## Workflow

### Session Start

Read: global CLAUDE.md → this CLAUDE.md → memory files → CHANGELOG.md

1. `git pull` — always before any work
2. `git status` — confirm clean tree
3. `git log --oneline -5` — where we left off
4. If touching more than 2 files → use plan mode first

### Session End

1. Run flake8, fix all issues
2. Run the app and confirm it still launches without errors
3. Update `CHANGELOG.md` (date + What Changed / Technical Details / Files Modified)
4. Update this `CLAUDE.md` (Recent Work section)
5. Sync memory: `cp ~/.claude/projects/<encoded-path>/memory/*.md .claude/memory/`
6. Sync best practices: `cp ~/.claude/best_practices.md best_practices.md`
7. Append one idea to `IDEAS.md` under `## Claude's Ideashop`
8. `git add` specific files, commit, push

### Confirmations

State exactly what you intend to change and why, then wait for approval before touching any file.
If the user re-asks after a proposal+question, just implement — they missed the prompt.

## Known GTK4 Issues & Workarounds

- **FileChooser**: use `.connect("response")` + `.present()` — never `.run()` (deprecated)
- **FlowBox clearing**: use `get_first_child()` + `remove()` loop, not deprecated `get_model()`
- **Ampersand in markup**: always escape as `&amp;` in `set_markup()`
- **Double initialization**: set initializing flag **before** first `set_active()` calls

## Recent Work

<!-- Most recent entries first -->
