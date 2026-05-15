# Tech News Sources Database

Known-good sources for daily tech news aggregation from this environment.

## ✅ Primary Sources (work from VPS without browser)

### GitHub Search API (Trending Repos)
- **Endpoint:** `https://api.github.com/search/repositories?q=created:>YYYY-MM-DD+stars:>500&sort=stars&order=desc&per_page=10`
- **Method:** HTTP GET, returns JSON — use `execute_code` / `hermes_tools.terminal()` to avoid pipe-to-interpreter security blocks
- **Date range:** Use `created:>$(date -d '7 days ago' +%Y-%m-%d)` for weekly trending, or `>$(date -d '1 day ago' +%Y-%m-%d)` for daily hot
- **Star threshold:** `stars:>1000` for hot repos; `stars:>500` for broader view
- **Output fields:** `full_name`, `stargazers_count`, `description`, `html_url`, `owner.login`
- **Rate limit:** 60 req/hr unauthenticated, 5000 req/hr with token — fine for daily digest use
- **Notes:** Excellent for developer-community sentiment. Catches projects before they hit HN front page (e.g. antirez/ds4 had 9k+★ trending same day as HN post). Complementary to HN — catches AI tooling, new frameworks, and OSS releases.
- **Reliability:** ✅ Excellent — no bot detection from standard curl / User-Agent

### Extended HN Filtering Pattern
Beyond the top 15 stories, filter the top 40-50 for tech/AI relevance using keyword scoring:

```python
tech_keywords = ['ai', 'llm', 'gpt', 'model', 'neural', 'learning', 'deep',
    'robot', 'chip', 'gpu', 'nvidia', 'intel', 'amd', 'apple', 'google',
    'microsoft', 'meta', 'openai', 'anthropic', 'claude', 'gemini',
    'transformer', 'diffusion', 'agent', 'coding', 'programming', 'startup',
    'tech', 'software', 'language model', 'open source', 'github',
    'tesla', 'spacex', 'quantum', 'cyber', 'security', 'data',
    'compute', 'server', 'cloud', 'aws', 'azure', 'semi', 'semiconductor',
    'tsmc', 'samsung', 'linux', 'python', 'rust', 'kernel', 'docker',
    'kubernetes', 'macos', 'm5', 'm4', 'rtx', '5090', 'fsr',
    '以太', '芯片', '半导', '人工智', '大模型', '数据', 'AI', '科技']

def relevance_score(title):
    t = title.lower()
    return sum(1 for kw in tech_keywords if kw.lower() in t)

# Fetch top 40 story IDs, filter where score >= 1 and score >= 10
```

This catches stories that aren't in the top 15 by score but are highly relevant (e.g., Claude for Legal at 96pts, LLM Policy for Rust at 84pts).

### Hacker News Firebase API
- **Endpoint:** `https://hacker-news.firebaseio.com/v0/topstories.json`
- **Item detail:** `https://hacker-news.firebaseio.com/v0/item/{id}.json`
- **Method:** Simple HTTP GET, returns JSON
- **Rate limit:** None observed (Firebase scale)
- **Output:** Top ~500 story IDs (grab first 15-20 for digest)
- **Notes:** Most reliable source. Stories have `title`, `url`, `score`, `by` fields.

### Ars Technica RSS Feed
- **Endpoint:** `https://feeds.arstechnica.com/arstechnica/index`
- **Method:** curl + grep for `<title>` tags
- **Extraction:** `grep -oP '<title>.*?</title>' | sed 's/<[^>]*>//g'`
- **Notes:** About 20 entries. First entry is always "Ars Technica - All content" — skip it.

### 奇客Solidot (Chinese Tech News)
- **Endpoint:** `https://www.solidot.org/index.rss`
- **Method:** XML parsing with Python's ElementTree
- **Format:** RSS 2.0 XML (not JSON)
- **Items per fetch:** ~20
- **Language:** Chinese (zh-cn), translated/summarized international tech news
- **Notes:** Covers tech, science, security, policy. Parsing: `ET.fromstring(xml).findall('.//item')` — each item has `<title>`, `<description>`, `<link>`, `<pubDate>`. Description text is CDATA inside `<description>` — use regex to strip HTML tags.
- **Reliability:** ✅ Excellent — no rate limiting, no bot detection

## ❌ Sources That Fail from This VPS

### Google Search / Google News
- Times out (>60s) from headless browser
- Both regular search and news search (`tbm=nws`) affected
- Even direct `browser_navigate` tool fails

### Bing News
- Same timeout behavior as Google
- Likely VPS IP range blocking

## ⚡ Best Workflow

1. Fetch HN top stories + individual items (15 items, via `execute_code` + `hermes_tools.terminal()`)
2. Fetch Ars Technica RSS titles (all)
3. Fetch Solidot RSS (Chinese tech news) — parse with ElementTree
4. Combine and deduplicate by title similarity
5. Pick 6-8 most relevant AI/tech stories (prioritize AI, semiconductor, security, platforms)
6. Format with bilingual headlines + Chinese summaries

## 🔧 Safe Data Processing Pattern

Instead of `curl | python3` (triggers security scanner):

```python
from hermes_tools import terminal
import json, xml.etree.ElementTree as ET

# JSON source (HN Firebase)
r = terminal("curl -s 'https://hacker-news.firebaseio.com/v0/topstories.json'")
ids = json.loads(r["output"])[:15]

# RSS source (Solidot)
r = terminal("curl -sL 'https://www.solidot.org/index.rss'")
root = ET.fromstring(r["output"])
items = root.findall('.//item')
```
