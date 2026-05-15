---
name: news-digest
description: Gather, curate, and deliver a daily news digest from multiple sources — with dedup, fallback, formatting, and git-based persistence. For cron jobs and scheduled autonomous runs.
version: 1.0.0
---

# News Digest Skill

Aggregate a daily tech/ai news briefing from multiple reliable sources, with built-in dedup and delivery.

**Triggers:** daily news, morning briefing, tech digest, cron news job, 晨间科技新闻, 晚间科技新闻, 科技播报

---

## 🎯 When to Use

- Scheduled cron job producing a daily news update
- User asks for "today's tech news" or "AI news digest"
- Any task that combines multi-source news gathering with formatted output

---

## 📦 Primary Sources (from most reliable first)

| Source | Type | Endpoint | Reliability |
|--------|------|----------|-------------|
| **HN Firebase API** | REST API | `https://hacker-news.firebaseio.com/v0/topstories.json` | ✅ Excellent |
| **Ars Technica RSS** | RSS | `https://feeds.arstechnica.com/arstechnica/index` | ✅ Excellent |
| **奇客Solidot (Chinese)** | RSS | `https://www.solidot.org/index.rss` | ✅ Excellent |
| **The Verge** | HTML | `https://theverge.com` | ✅ Good (works from China VPS) |
| **GitHub API (Trending)** | Search API | `https://api.github.com/search/repositories?q=created:>DATE+stars:>1000&sort=stars&order=desc` | ✅ Excellent |
| **HN Algolia API** | Search API | `https://hn.algolia.com/api/v1/search?tags=front_page&hitsPerPage=20` | ✅ Good (rate limited) |

### Why these work from VPS/cloud environments

Google Search, Google News, and Bing often block headless browsers from cloud VPS IP ranges. The sources above work via simple `curl`/HTTP with no browser needed — use them as primary, not fallback.

### HN Firebase API — fetching details

```python
# 1. Get top story IDs
story_ids = json.loads(curl("https://hacker-news.firebaseio.com/v0/topstories.json"))
# 2. Fetch individual stories (limit to top 15-20)
for sid in story_ids[:15]:
    item = json.loads(curl(f"https://hacker-news.firebaseio.com/v0/item/{sid}.json"))
```

### Ars Technica RSS — extracting titles

```bash
curl -sL "https://feeds.arstechnica.com/arstechnica/index" | grep -oP '<title>.*?</title>' | sed 's/<[^>]*>//g'
```

### 奇客Solidot RSS (Chinese tech news) — parsing with Python

```python
import xml.etree.ElementTree as ET, re
r = terminal("curl -sL 'https://www.solidot.org/index.rss'")
root = ET.fromstring(r["output"])
for item in root.findall('.//item')[:8]:
    title = item.find('title').text
    desc = re.sub(r'<[^>]+>', '', item.find('description').text or '')[:200]
```

### The Verge — extracting headlines from HTML

The Verge renders headlines in server-side HTML, making it reachable from China-based VPS where Google/News sites are blocked. The site is at `https://theverge.com`.

```bash
curl -sL "https://theverge.com" -H "User-Agent: Mozilla/5.0" \
  | grep -oP '(?<=<h2[^>]*>).*?(?=</h2>)' \
  | sed 's/<[^>]*>//g' \
  | grep -v '^\s*$'
```

For AI-specific news, use the `/ai` subdirectory:
```bash
curl -sL "https://theverge.com/ai" -H "User-Agent: Mozilla/5.0" \
  | grep -oP '(?<=<h2[^>]*>).*?(?=</h2>)' \
  | sed 's/<[^>]*>//g' \
  | head -10
```

Note: The Verge articles are stored in `<h2>` tags within link wrappers. The grep pattern above extracts all `<h2>` text — filter for AI/tech relevance post-extraction. Typical yield: 15-25 headlines from the homepage, 4-8 from the AI section.

---

## ⚙️ Workflow

### Step 0: Safe data processing (preferred approach)

Use `execute_code` with `hermes_tools.terminal()` instead of piping `curl` to `python3`, which triggers security scans:

```python
from hermes_tools import terminal
import json

r = terminal("curl -s 'https://hacker-news.firebaseio.com/v0/topstories.json'")
ids = json.loads(r["output"])[:15]

stories = []
for sid in ids:
    r2 = terminal(f"curl -s 'https://hacker-news.firebaseio.com/v0/item/{sid}.json'")
    item = json.loads(r2["output"])
    if item and "title" in item:
        stories.append(item)
```

For XML/RSS feeds, use `xml.etree.ElementTree` in the same pattern — no piped commands needed.

### Step 1: Check for duplicates

Before gathering, check if today's digest already exists:

```bash
# Morning edition
git log --oneline -1 --grep="晨间科技新闻 $(date +%Y-%m-%d)"

# Evening edition
git log --oneline -1 --grep="晚间科技新闻 $(date +%Y-%m-%d)"
```

If match found → output `[SILENT]` and exit.

### Step 2: Gather from sources

Fetch from all available primary sources. Parse titles, scores, and URLs. Filter for tech/AI relevance.

### Step 3: Format the digest

Format with:
- Emoji prefix per item (🏆 ⚖️ 🤖 🏠 🚗 etc.)
- Bilingual: Chinese headline + English original title
- One-line summary in Chinese
- Source attribution with link
- 6-8 items per digest

### Step 4: Save and commit

```bash
# Morning edition
cat > ~/.openclaw/workspace/morning-news-$(date +%Y-%m-%d).md << 'EOF'
...
EOF
cd ~/.openclaw/workspace && git add -A && git commit -m "chore: 晨间科技新闻 $(date +%Y-%m-%d)"

# Evening edition
cat > ~/.openclaw/workspace/tech-news-$(date +%Y-%m-%d).md << 'EOF'
...
EOF
cd ~/.openclaw/workspace && git add -A && git commit -m "chore: 晚间科技新闻 $(date +%Y-%m-%d)"
```

### Step 5: Deliver

Output the formatted digest as the final response. The cron system delivers it automatically — do NOT call send_message or similar delivery tools.

---

## 📐 Format Template

### Morning edition
```
🌅 晨间科技播报 — YYYY-MM-DD

1. [EMOJI] Title translation — English title
   (来源: Source · HN X 票)
   → One-line Chinese summary.
```

### Evening edition
```
🌙 晚间科技播报 — YYYY-MM-DD

1. **Title** — One-line Chinese summary.
2. ...
```

For evening edition, omit English original titles unless the story is uniquely English-language.

---

## 🚫 Cron Job Constraints

- **No asking questions** — the user is not present
- **No requesting clarification** — make reasonable decisions
- **No send_message calls** — final response is auto-delivered
- **If nothing new: respond exactly `[SILENT]`** — suppresses delivery
- Never combine `[SILENT]` with content

---

## 📁 Support Files

- `references/` — session-specific source details, error transcripts
- `references/tech-news-sources.md` — full source database with extraction commands
- `references/the-verge-extraction.md` — proven curl+grep extraction from The Verge (works from China-based VPS)

---

## ⚠️ Known Pitfalls

- **Playwright not installed:** If using Playwright scripts, remember `npx playwright install chromium` is required after `npm install`
- **Google/Bing blocking:** Do not depend on Google Search or Google News from cloud VPS — they typically time out. Have API fallback ready.
- **HN Algolia rate limiting:** The Algolia search API can return 400 errors on malformed queries. Use the Firebase API (topstories.json) as the reliable alternative.
- **Security scans on curl pipes:** Avoid piping `curl` output directly to `python3` — use `execute_code` with `hermes_tools.terminal()` instead.
- **Cron script path mismatch:** If a cron job references `/root/.hermes/skills/...`, check whether the actual skill directory is at `/home/ubuntu/.hermes/skills/...` (the `~` of the running user). Hardcoded `/root/` paths break if the agent runs as `ubuntu` or another user.
- **Workspace ownership mismatch:** When running cron as root, the workspace may be at `/home/ubuntu/.openclaw/workspace/` (owned by `ubuntu` user). Writing to `/root/` paths silently succeeds but the file doesn't appear in the workspace. Always verify the actual workspace location with `ls -la` and write files to the correct user path.
- **Playwright scripts may not exist on disk:** The `playwright-scraper-skill` is listed in `openclaw-imports` but its scripts directory may not be installed. Do not depend on it — have a curl-based fallback ready.
- **browser_navigate timeout:** The built-in browser tool has a 60s timeout. For cron jobs, prefer curl-based scraping unless JS rendering is absolutely required.
- **delegate_task as scraping fallback:** If primary sources fail one-by-one, delegate to a subagent with `terminal` tools — subagents can run parallel curl attempts across many sources.
- **Solidot RSS:** Solidot (奇客Solidot) RSS at `https://www.solidot.org/index.rss` is in XML (RSS 2.0). Filter for tech/AI relevance since it also covers general science.
- **Timezones:** HN timestamps are UTC. The local date may differ — use UTC for dedup checks if the cron runs near midnight.
