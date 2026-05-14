#!/bin/bash
# Hermes Runtime Backup Script
# Copies runtime data from ~/.hermes/ to the git-tracked hermes-all repo
# and pushes to GitHub

set -e

HERMES_DIR="/home/ubuntu/.hermes"
BACKUP_DIR="/home/ubuntu/hermes-all"

# Copy important runtime data (not secrets)
cp "$HERMES_DIR/config.yaml" "$BACKUP_DIR/config.yaml" 2>/dev/null || true

# Memories (persistent memory of the agent)
rsync -a "$HERMES_DIR/memories/" "$BACKUP_DIR/memories/" 2>/dev/null || true

# Sessions (conversation history)
rsync -a "$HERMES_DIR/sessions/" "$BACKUP_DIR/sessions/" 2>/dev/null || true

# State database
cp "$HERMES_DIR/state.db" "$BACKUP_DIR/state.db" 2>/dev/null || true
cp "$HERMES_DIR/state.db-shm" "$BACKUP_DIR/state.db-shm" 2>/dev/null || true
cp "$HERMES_DIR/state.db-wal" "$BACKUP_DIR/state.db-wal" 2>/dev/null || true

# Logs (recent)
rsync -a "$HERMES_DIR/logs/" "$BACKUP_DIR/logs/" 2>/dev/null || true

# Cron output
rsync -a "$HERMES_DIR/cron/output/" "$BACKUP_DIR/cron/output/" 2>/dev/null || true

# Cron jobs config
cp "$HERMES_DIR/cron/jobs.json" "$BACKUP_DIR/cron/jobs.json" 2>/dev/null || true

# Skills (all user skills, excluding plugins)
rsync -a --exclude='hermes-agent' "$HERMES_DIR/skills/" "$BACKUP_DIR/skills/" 2>/dev/null || true

# SOUL.md
cp "$HERMES_DIR/SOUL.md" "$BACKUP_DIR/SOUL.md" 2>/dev/null || true

# Channel directory
cp "$HERMES_DIR/channel_directory.json" "$BACKUP_DIR/channel_directory.json" 2>/dev/null || true

cd "$BACKUP_DIR"

# Only commit if there are changes
git add -A 2>/dev/null
git diff --cached --quiet && echo "nothing to commit" && exit 0

git commit -m "backup: $(date '+%Y-%m-%d %H:%M')"

# Push with direct connection (no proxy) since server can reach GitHub directly
git -c http.proxy="" push origin main 2>/dev/null && echo "backup pushed" || echo "push failed (network?)"
