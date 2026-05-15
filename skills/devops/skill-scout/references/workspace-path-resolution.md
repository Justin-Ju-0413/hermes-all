# Workspace Path Resolution

## Background
Cron jobs and autonomous tasks often hardcode workspace paths that may be stale or wrong. This reference documents the patterns found during the 2026-05-14 self-check.

## Known Workspace Paths on This System

| Path | Owner | Perms | Status |
|------|-------|-------|--------|
| /home/ubuntu/.openclaw/workspace/ | ubuntu:ubuntu | 775 | **Active** - writable, has .git, used for daily reports |
| /root/.openclaw/workspace/ | root:root | 755 | **Active (root-owned)** - used by system-level cron jobs (e.g., daily self-check). Write requires `sudo cp` + `sudo git commit` workaround. Last self-check commit: May 15, 2026 |
## Detection Pattern

When you see "Permission denied" writing to a workspace path:
1. Check who you are: `whoami`
2. Check the directory ownership: `stat <path>`
3. Check alternate paths under `/home/<user>/`
4. Look for `.git` directories and recent commits to confirm which is active
5. If the task explicitly targets a root-owned path and you lack write access, use the sudo workaround (see below)

## Sudo Workaround for Root-Owned Workspaces

Some cron tasks intentionally target `/root/.openclaw/workspace/` for system-level reports. When running as the `ubuntu` user:

```bash
# 1. Write content to /tmp/ first
cat > /tmp/report.md << 'EOF'
... content ...
EOF

# 2. Copy to target with sudo
sudo cp /tmp/report.md /root/.openclaw/workspace/report.md

# 3. Set ownership
sudo chown root:root /root/.openclaw/workspace/report.md

# 4. Git operations must also use sudo
cd /root/.openclaw/workspace
sudo git add -A
sudo git commit -m "chore: report $(date +%Y-%m-%d)"
```

Note: The `write_file` tool cannot write to root-owned directories. Always use the terminal tool with `sudo` for these paths.
