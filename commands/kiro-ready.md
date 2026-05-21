Assess whether the KIRO ISO is ready to release. Produce a GO / NO-GO verdict with supporting evidence.

kiro-audit lives on the Kiro VirtualBox guest — SSH in via sshpass to run it.
SSH credentials: user=erik, password=erik, host=127.0.0.1, port=2022

Run ALL of the following steps sequentially and collect output before rendering the verdict:

## Step 1 — Git state of the 5 source repos

For each repo below, run `git status --short` and `git log --oneline -3`:
- `/home/erik/KIRO/kiro-iso`
- `/home/erik/KIRO/kiro-iso-next`
- `/home/erik/KIRO/kiro-calamares-config`
- `/home/erik/KIRO/kiro-calamares-config-next`
- `/home/erik/EDU/edu-system-files`

Flag any repo with: uncommitted changes, commits not pushed to origin (`git status -b`), or a detached HEAD.

## Step 2 — TODO blockers

Read `/home/erik/KIRO/kiro-iso/TODO.md`.
Flag anything in **In Progress** or **Up Next** sections — these are potential release blockers.
Items in **Backlog** or **Done** are not blockers.

## Step 3 — Last distro test result

Read `/home/erik/KIRO/kiro-iso/DISTRO_TESTING.md` (first 80 lines — newest entry is at the top).
Report: date, version, environment, PASS/WARN/FAIL counts, and any open FAILs.

## Step 4 — kiro-audit on the Kiro VirtualBox guest

Run:
```
sshpass -p erik ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 -p 2022 erik@127.0.0.1 "echo 'erik' | sudo -S kiro-audit 2>&1"
```

If the VM is unreachable, note it and continue without this step.

## Step 5 — ISO build recency

Run:
```
ls -lh /home/erik/KIRO/kiro-iso/out/*.iso 2>/dev/null || echo "No ISO in out/"
```
Report the ISO filename, size, and timestamp.

---

## Verdict

Render a clear **GO** or **NO-GO** block followed by a two-column table:

| Check                              | Status            |
|------------------------------------|-------------------|
| All 5 repos clean + pushed         | PASS / FAIL       |
| No TODO blockers                   | PASS / FAIL       |
| Last distro test: FAIL count       | 0 / N             |
| kiro-audit: FAIL count             | 0 / N             |
| ISO built recently (within 7 days) | PASS / FAIL / N/A |

**GO** = all PASS and kiro-audit FAIL = 0.
**NO-GO** = any FAIL. List each blocker explicitly with the fix needed.

If $ARGUMENTS is provided (e.g. `/kiro-ready quick`), skip steps 4 and 5 and use cached kiro-audit results from memory if available.
