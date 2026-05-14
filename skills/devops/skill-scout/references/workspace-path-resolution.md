# Workspace Path Resolution

## Background
Cron jobs and autonomous tasks often hardcode workspace paths that may be stale or wrong. This reference documents the patterns found during the 2026-05-14 self-check.

## Known Workspace Paths on This System

| Path | Owner | Perms | Status |
|------|-------|-------|--------|
| /home/ubuntu/.openclaw/workspace/ | ubuntu:ubuntu | 775 | **Active** - writable, has .git, used for daily reports |
| /root/.openclaw/workspace/ | root:root | 755 | Stale - root-owned, "Permission denied" for ubuntu user, no updates since May 8 |

## Detection Pattern
When you see "Permission denied" writing to a workspace path:
1. Check if you're running as a different user (`whoami`)
2. Check the directory ownership (`stat <path>`)
3. Check alternate paths under /home/<user>/
4. Look for `.git` directories to confirm which one is active

The active `.openclaw/workspace` will have recent commits and files. The stale one won't.
