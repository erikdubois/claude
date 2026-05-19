Deep comparison between the kiro-iso / kiro-calamares-config / edu-system-files source trees and the actual installed state on the Kiro VirtualBox VM. Goal: find mismatches, leftover live-environment files, deprecated config, and anything that changed in source but didn't land correctly on the installed system.

SSH credentials for the Kiro VirtualBox guest: user=erik, password=erik, host=127.0.0.1, port=2022.
SSH command prefix: `sshpass -p erik ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 -p 2022 erik@127.0.0.1`

Run all steps sequentially. Do NOT skip any step.

---

## Step 1 — Source file inventory

List every file in the airootfs overlay and edu-system-files overlay:

```bash
find /home/erik/KIRO/kiro-iso/archiso/airootfs/etc -type f | sort
find /home/erik/KIRO/kiro-iso/archiso/airootfs/usr -type f | sort
find /home/erik/EDU/edu-system-files/etc -type f | sort
find /home/erik/EDU/edu-system-files/usr -type f | sort
```

## Step 2 — Critical security file checks on VM

```bash
# 10-archiso.conf must be absent — if present, PermitRootLogin yes ships to users
ls -la /etc/ssh/sshd_config.d/
cat /etc/ssh/sshd_config.d/10-archiso.conf 2>/dev/null && echo "PROBLEM: 10-archiso.conf present" || echo "GOOD: 10-archiso.conf absent"

# CUPS permissions
ls -la /etc/cups/classes.conf /etc/cups/printers.conf 2>/dev/null
cat /etc/tmpfiles.d/cups-permissions.conf 2>/dev/null || echo "PROBLEM: cups-permissions.conf missing"
```

## Step 3 — Live-environment survivors on VM

Files placed in airootfs for the live/install environment that should NOT survive to the installed system:

```bash
# do-not-suspend: intended for live env, prevents suspend during install
ls /etc/systemd/logind.conf.d/ && cat /etc/systemd/logind.conf.d/do-not-suspend.conf 2>/dev/null || echo "do-not-suspend.conf absent"

# getty autologin: must be removed by kiro_final
ls /etc/systemd/system/getty@tty1.service.d/ 2>/dev/null || echo "autologin.conf absent (good)"

# polkit nopasswd: must be removed by kiro_final
ls /etc/polkit-1/rules.d/ 2>/dev/null

# sudoers g_wheel: must be removed by kiro_final
ls /etc/sudoers.d/ 2>/dev/null

# archiso mkinitcpio hooks must NOT be present
grep -E 'archiso|archiso_loop_mnt|archiso_pxe' /etc/mkinitcpio.conf && echo "PROBLEM: archiso hooks in mkinitcpio" || echo "GOOD: no archiso hooks"
```

## Step 4 — Journal warnings from deprecated/duplicate config

```bash
# Check for known deprecated key warnings from airootfs files
journalctl -b -p warning --no-pager | grep -E 'Unknown key|deprecated|ignored' | grep -v kernel | head -20
```

## Step 5 — Sysctl live values vs expected

```bash
sysctl kernel.kptr_restrict kernel.dmesg_restrict kernel.yama.ptrace_scope \
       kernel.unprivileged_bpf_disabled kernel.perf_event_paranoid \
       fs.suid_dumpable net.ipv4.conf.all.send_redirects \
       net.ipv4.tcp_syncookies kernel.sysrq vm.swappiness vm.overcommit_memory
```

Expected values: kptr_restrict=2, dmesg_restrict=1, ptrace_scope=1, unprivileged_bpf_disabled=1,
perf_event_paranoid=3, suid_dumpable=0, send_redirects=0, tcp_syncookies=1, sysrq=244, swappiness=150, overcommit_memory=1.

## Step 6 — udev rules present

```bash
ls -la /etc/udev/rules.d/
```

Expected: 60-io-scheduler.rules, 60-ioschedulers-tuning.rules, 61-audio-power.rules,
62-network-optimization.rules, 63-usb-optimization.rules, 64-gpu-optimization.rules,
65-storage-optimization.rules, 66-input-optimization.rules, 67-laptop-optimization.rules,
68-sound-power.rules.

## Step 7 — edu-system-files scripts on VM

```bash
ls -la /usr/local/bin/kiro-* /usr/local/bin/pci-latency /usr/local/bin/get-nemesis /usr/local/bin/skel 2>/dev/null
```

Expected: kiro-audit, kiro-diag, kiro-enable-ssh, kiro-fix-gpg-conf, kiro-fix-mirrors,
kiro-fix-pacman-conf, kiro-fix-pacman-keys, kiro-get-mirrors, kiro-install-tools,
kiro-iso-version, kiro-lint, kiro-probe, kiro-set-cores, kiro-verify, kiro-which-vga,
pci-latency, get-nemesis, skel.

## Step 8 — Duplicate or conflicting config files

```bash
# system.conf.d — should not have both memory-accounting.conf (airootfs) and 90-memory-accounting.conf (package)
ls -la /etc/systemd/system.conf.d/

# sysctl.d — should only have 99-kiro-optimizations.conf (package), not a stale airootfs copy
ls -la /etc/sysctl.d/
```

## Step 9 — Git state: any re-added files after a delete commit?

Run on the HOST (not VM):

```bash
# Check if 10-archiso.conf was deleted and re-added
git -C /home/erik/KIRO/kiro-iso log --oneline -5 -- archiso/airootfs/etc/ssh/sshd_config.d/10-archiso.conf
ls -la /home/erik/KIRO/kiro-iso/archiso/airootfs/etc/ssh/sshd_config.d/ 2>/dev/null || echo "sshd_config.d empty or absent"

# Show any files that exist on disk but whose last git action was a delete
git -C /home/erik/KIRO/kiro-iso status --short
git -C /home/erik/EDU/edu-system-files status --short
```

---

## Report format

After all steps, present findings in three blocks:

### PROBLEMS (must fix before release)
List each issue: what was found, where, and the exact fix needed.

### WARNINGS (should fix, not blocking)
List each: what generates a warning, why, suggested fix.

### ALL CLEAR
List items that were specifically checked and confirmed correct.

At the end, state: **Source-to-VM integrity: CLEAN** or **Source-to-VM integrity: N issues found**.

If $ARGUMENTS is provided (e.g. `/kiro-check ssh` or `/kiro-check sysctl`), focus only on that subsystem and skip unrelated steps.
