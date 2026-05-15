# System Diagnostics Commands

Reusable command patterns for autonomous cron jobs that need to report system health. These cover the standard "每日自检" (daily self-check) pattern.

## Basic System Info

```bash
# Uptime and load
uptime                                       # load average + uptime

# Disk usage
df -h /                                      # root partition usage

# Memory
free -h                                      # total vs used vs available

# Running processes for service health
ps aux | grep -E "hermes|openclaw|node" | grep -v grep

# Process counts by service
ps aux | grep -c "[h]ermes"                  # hermes process count
ps aux | grep -c "[n]ode"                    # node process count
```

## Git Log Inspection (daily self-check pattern)

```bash
# Today's commits before a cutoff time
cd <workspace-path>
git log --oneline --since="$(date '+%Y-%m-%d') 00:00" --until="$(date '+%Y-%m-%d') 06:00" 2>/dev/null

# Today's commits matching specific keywords
git log --oneline --since="$(date '+%Y-%m-%d') 00:00" 2>/dev/null | grep -E "自检|self.?check|health|status" | head -10

# Recent commits (last N)
git log --oneline -20 2>/dev/null

# Show commit with dates
git log --oneline --since="7 days ago" 2>/dev/null
```

## Git Commit (for report persistence)

```bash
# After writing a report file:
cd <workspace-path>

# Determine ownership and use appropriate approach
if [ "$(stat -c '%U' .)" = "root" ]; then
    sudo git add -A
    sudo git commit -m "chore: <action> $(date +%Y-%m-%d)"
else
    git add -A
    git commit -m "chore: <action> $(date +%Y-%m-%d)" || true
fi
```

## Workspace Path Detection

```bash
# Check which workspace has active commits
for p in /root/.openclaw/workspace /home/ubuntu/.openclaw/workspace; do
    if [ -d "$p/.git" ]; then
        last_commit=$(cd "$p" && git log --oneline -1 2>/dev/null)
        owner=$(stat -c '%U' "$p")
        echo "$p — owner: $owner — last commit: ${last_commit:-none}"
    fi
done
```

## Security Checks

```bash
# fail2ban status
sudo fail2ban-client status 2>/dev/null | grep -oP 'Total failed:\s+\K\d+'

# Failed SSH logins (last 24h)
sudo journalctl -u ssh --since "24 hours ago" 2>/dev/null | grep -c "Failed password" || echo 0

# Suspicious processes
ps aux --sort=-%mem | head -5
```

## Complete Health Check One-Liner

```bash
echo "Uptime: $(uptime -p) | Load: $(uptime | grep -oP 'load average:.*' | cut -d: -f2) | Disk: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}') | Mem: $(free -h | awk '/^Mem/{print $3"/"$2}')"
```
