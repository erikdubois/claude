Run a comprehensive system log check to assess the health of the system and the effect of recently installed or updated packages (e.g. edu-system-files, kiro-system-files, nemesis-system-files, or any Arch package that drops files into /etc/, /usr/lib/udev/rules.d/, /usr/lib/systemd/, /usr/share/, etc.).

IMPORTANT: Do NOT use `sudo dmesg` — it cannot authenticate non-interactively. Use `journalctl -k` for kernel messages instead.

Run ALL of the following commands sequentially (not in parallel — a failure must not cancel remaining commands) and collect the output before summarising:

1. `journalctl -k -p warning --since "3 hours ago" --no-pager` — kernel warnings and errors (replaces sudo dmesg)
2. `journalctl -p err -n 100 --since "3 hours ago" --no-pager` — systemd journal errors
3. `journalctl -p warning -n 80 --since "3 hours ago" --no-pager` — warnings (for context)
4. `journalctl -u systemd-udevd -n 50 --since "3 hours ago" --no-pager` — udev daemon (udev rules from system-files packages land here)
5. `journalctl -b --priority=err --no-pager` — all errors since last boot
6. `systemctl --failed` — any systemd units that have failed
7. `tail -80 /var/log/pacman.log` — recent pacman transactions (installs, upgrades, removals)
8. `journalctl -u NetworkManager -p warning --since "3 hours ago" --no-pager` — network config changes
9. `journalctl -u sddm -p warning --since "3 hours ago" --no-pager` — display manager issues (login keyring, PAM, etc.)
10. `ls /etc/udev/rules.d/` — local udev rules (from system-files packages)

After collecting all output, present a structured summary with these sections:

**Kernel Issues** — kernel warnings and errors, note if related to udev rules, drivers, or hardware
**Udev Problems** — missing callout binaries, sysfs attribute failures, invalid rule syntax, rule errors — cross-reference with /etc/udev/rules.d/
**Service Failures** — failed units, stopped services, PAM errors
**Package Activity** — what pacman installed/removed/upgraded recently, flag anything system-config related
**Network / Display** — NM and SDDM warnings
**Pre-existing vs New** — flag anything that looks like it appeared after the most recent pacman transaction

If $ARGUMENTS is provided, use it as a package name or time window to focus the check (e.g. `/syscheck edu-system-files` or `/syscheck 30min`).
