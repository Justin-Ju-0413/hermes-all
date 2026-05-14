# last30days-skill Ecosystem Profile

**Repo**: `mvanhorn/last30days-skill`
**Stars**: ~25,812 (May 2026)
**Status**: #1 GitHub Trending, daily-active maintainer
**Author**: @mvanhorn
**Install**: `clawhub install last30days-official`

## What It Does

Multi-source AI research engine. Searches Reddit (public JSON), X, YouTube transcripts, TikTok, HN, Polymarket, GitHub, Threads, Pinterest, Bluesky, Perplexity Sonar in parallel. Scores results by real engagement (upvotes, likes, Polymarket odds) — not SEO. Agent judges synthesize into one brief.

## Why Track It

- **Ecosystem benchmark** — represents the "multi-source social search" category that is trending across agent skills. New skills that copy or compete with it are high-signal.
- **Star growth indicator** — its growth rate reflects overall ecosystem health. If it plateaus or drops, agent-skill interest may be cooling.
- **Install scope** — requires browser cookies + API keys. Skills in this pattern carry elevated security scrutiny.

## Source Capabilities

| Source | Auth Required | Risk |
|--------|--------------|------|
| Reddit | None (public JSON) | 🟢 |
| Hacker News | None (Firebase API) | 🟢 |
| GitHub | Optional (token) | 🟢 |
| Polymarket | None | 🟢 |
| X/Twitter | Cookies + API key | 🟡 |
| YouTube | API key | 🟡 |
| TikTok | ScrapeCreators | 🟡 |
| Perplexity | OpenRouter key | 🟡 |

## Security Notes

- `chrome_cookies.py` / `cookie_extract.py` extract browser cookies for platform auth — requires same-user access to Chrome profile
- No config modification, no hooks, no auto-execution
- 145 Python files, well-structured, 1012 tests
- No known CVEs or open security issues
- Risk level: 🟡 — recommend dedicated/isolated environment if cookie extraction is used

## Related Ecosystem Skills

- `prompt-security/clawsec` — security auditing (different category, complementary)
- Respectful-judasiscariot925/autocli-skill — similar "multi-platform CLI" concept, but 0 stars and unaudited
