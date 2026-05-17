# Universal Memory — Erik / Claude Code

These memories apply to all projects. Copy to `~/.claude/projects/<project>/memory/` or `.claude/memory/` in the repo.

## Core Workflow Rules
- [No Changes Without Confirmation](feedback_no_changes_without_consent.md) — Never add/remove/modify code without explicit user confirmation first
- [Re-ask = Implicit Confirm](feedback_confirm_re_ask.md) — If user re-asks after Claude proposed + asked "Confirm?", just implement — they missed the prompt
- [Just Go Ahead](feedback_just_go_ahead.md) — After plan approval, execute all phases without mid-plan check-ins; use ✓/▶ progress overview

## Git Rules
- [Git Management — Multi-Tab](feedback_git_management.md) — Claude owns all git ops; always git pull before any task; multiple tabs means work may already be done
- [User Handles All Commits](feedback_user_commits.md) — Confirm → Claude edits, flake8, commits, pushes; never remind user to commit; never `git add .`
- [Never Establish Git Tags](git_tag_never.md) — User forbids git tags completely; never suggest or implement
- [No GitHub CLI](feedback_no_gh_cli.md) — gh is not installed; never use it; use git diff/log for PR review work

## Python Code Style
- [Auto-Fix All Flake8 Issues](feedback_flake8_auto_fix.md) — Fix all violations automatically; never ask permission; re-run to verify
- [Docstring Rule — PEP 257](feedback_docstring_rule.md) — Public functions: one-line docstring; private (_prefix): none required; never multi-paragraph
- [Section Dividers Kept](feedback_section_dividers.md) — `# ── Name ──` dividers kept in long functions (50+ lines); not in short functions
- [Two-street logging pattern](feedback_two_street_logging.md) — always-visible `log_*` calls vs `--debug`-only `debug_print` for source/target paths
- [Always Communicate Without --debug](feedback_debug_vs_log.md) — User-facing actions need log_success/log_info, not just debug_print
- [Logging Attention](feedback_logging_attention.md) — Always audit both success and failure paths for log_* + notification; capture Popen return codes

## GTK4 Patterns
- [GTK Callback _widget Convention](feedback_widget_underscore.md) — Unused GTK signal params must be `_widget` not `widget`; project-wide pattern
- [Widget Naming Convention](feedback_widget_naming.md) — No hbox1/hbox2/vbox3; use descriptive names; update ALL references before renaming self.* attributes
- [GTK Markup Ampersand](feedback_gtk_markup_ampersand.md) — `&` must be `&amp;` in `set_markup()` or label silently renders nothing
- [No blocking subprocess for terminals](feedback_no_blocking_subprocess.md) — Never `subprocess.call()` for terminal launches; use Popen + daemon thread
- [Alacritty --hold vs read](feedback_alacritty_hold_vs_read.md) — Never combine `--hold` with `read -p`; use one or the other; ATT preference is `read -p` without `--hold`
- [Install/Uninstall Pattern](feedback_install_uninstall_pattern.md) — All installs/uninstalls use alacritty terminal with all commands visible; daemon thread; transparency is core
- [UI Naming Convention — Page vs Tab](feedback_ui_naming_convention.md) — Page = sidebar entry; Tab = sub-section inside a page

## Session Hygiene
- [Console Output Standard](console_output_standard.md) — Template for all user-facing messages: action + optional debug + result
- [Session End Includes TODO](feedback_session_end_todo.md) — End-of-session wrap-up must include reviewing and updating TODO.md
- [Dev Mode Silence](feedback_dev_mode_silence.md) — Never mention `--dev` mode in UI text, logs, or conversation; hidden means hidden
- [No Repeat Tips](feedback_no_repeat_tips.md) — Always read best_practices.md before writing tips; check by concept not just wording
- [No Version Mention](feedback_no_version_mention.md) — Never mention version numbers in conversation
