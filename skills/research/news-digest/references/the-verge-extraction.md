# The Verge Extraction — Reference

## Why The Verge

From China-based VPS (IP: 101.33.227.246), most major news sites are unreachable:
- Google News / Google Search → timeout
- Hacker News HTML page → loads but JS-rendered (use Firebase API instead)
- TechCrunch → JS-rendered (Next.js)
- Techmeme → JS-rendered

The Verge renders headlines server-side and is reliably reachable.

## Extraction Commands

Extract all homepage headlines:
```bash
curl -sL "https://theverge.com" -H "User-Agent: Mozilla/5.0" \
  | grep -oP '(?<=<h2[^>]*>).*?(?=</h2>)' \
  | sed 's/<[^>]*>//g' \
  | grep -v '^\s*$'
```

Extract AI-specific headlines:
```bash
curl -sL "https://theverge.com/ai" -H "User-Agent: Mozilla/5.0" \
  | grep -oP '(?<=<h2[^>]*>).*?(?=</h2>)' \
  | sed 's/<[^>]*>//g' \
  | head -10
```

Extract AI section + top stories (for richer coverage):
```bash
curl -sL "https://theverge.com/ai" -H "User-Agent: Mozilla/5.0" | grep -oP '(?<=<h2[^>]*>).*?(?=</h2>)' | sed 's/<[^>]*>//g'
curl -sL "https://theverge.com/tech" -H "User-Agent: Mozilla/5.0" | grep -oP '(?<=<h2[^>]*>).*?(?=</h2>)' | sed 's/<[^>]*>//g'
```

## Headline Density

| Section | Typical Headline Count |
|---------|----------------------|
| Homepage (/) | 15-25 |
| AI (/ai) | 4-8 |
| Tech (/tech) | 8-12 |

## Known Coverage Areas (May 2026)

Typical themes from successful extractions:
- Musk v. OpenAI trial / AI regulation stories
- xAI, Google Gemini, Meta AI product launches
- Microsoft/Google/Apple AI strategy shifts
- Android/iOS platform updates
- Hardware (consoles, AR glasses, cameras)
- Gaming (Nintendo Switch 2, Xbox, Valve)

## Pitfalls

- HTML structure may change if The Verge redesigns
- `grep -oP` requires Perl-compatible regex support in grep
- Some `<h2>` tags contain navigation/UI text — filter these out post-extraction
- The `-H "User-Agent: Mozilla/5.0"` header is required or the site returns a mobile/blocked version
