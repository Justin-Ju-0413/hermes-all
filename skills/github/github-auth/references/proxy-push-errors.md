# Proxy Push Errors Reference

Reproduction transcript for `git push` failures over SOCKS5 proxy in China.

## Error Signatures

### HTTP 408 / curl 22
```
error: RPC failed; HTTP 408 curl 22 The requested URL returned error: 408
send-pack: unexpected disconnect while reading sideband packet
fatal: the remote end hung up unexpectedly
```
Likely cause: Large push over SOCKS5 proxy times out. Smaller `git ls-remote` works fine.

### curl 65 / rewind error
```
error: unable to rewind rpc post data - try increasing http.postBuffer
error: RPC failed; curl 65 seek callback returned error 1
send-pack: unexpected disconnect while reading sideband packet
fatal: the remote end hung up unexpectedly
```
Likely cause: git pack exceeds default `http.postBuffer` (1MB) over proxy.

## Environment

- Proxy: SOCKS5 at 127.0.0.1:7890 (Mihomo mixed-port)
- Repo: ~6.6MB with state.db, sessions, memories tracked
- OS: Ubuntu 24.04
- Git push target: github.com via HTTPS

## Tried and Fails

1. **Increasing http.postBuffer to 500MB** — resolves curl 65 but still gets HTTP 408
2. **HTTPS with PAT** — auth succeeds but push times out
3. **SOCKS5 proxy** — small API calls work (curl github.com/zen returns 200)

## Reliable Workaround: Three Options

| Priority | Solution | When |
|----------|----------|------|
| 1 | **Test direct access first** | Many cloud VPS in China (Tencent Cloud, Aliyun) have direct GitHub access. Try `curl https://api.github.com/zen` — if it works, just `git -c http.proxy="" push origin main` |
| 2 | **Switch to SSH** | SSH handles large pack transfers more reliably over SOCKS5 proxies. `git remote set-url origin git@github.com:<user>/<repo>.git` |
| 3 | **Orphan branch + gc** | If the repo has large files in history, even direct push may fail. Clean history first (see github-repo-management skill section 10) |

## Session Transcript: Discovered Direct Access

Full reproduction from a real session on Tencent Cloud Lighthouse (Ubuntu 24.04):

### Initial State
- Server: Tencent Cloud Lighthouse, China region
- Proxy: Mihomo SOCKS5 at 127.0.0.1:7890 (global proxy for WhatsApp)
- Git was configured with `git config --global http.proxy socks5://127.0.0.1:7890`
- Repo pack: ~20MB (state.db, node_modules in history)

### What Was Tried

1. git push -f → HTTP 408
2. Increased http.postBuffer to 500MB → still HTTP 408
3. Orphan branch + gc → pack dropped to 7.48MB → still HTTP 408
4. `git -c http.proxy="" push` → SUCCEEDED

### Root Cause

The server had direct outbound access to GitHub all along. The proxy was configured globally for WhatsApp/Browser traffic but was not needed for git. The SOCKS5 proxy (Mihomo mixed-port) cannot sustain a 4MB+ upload over HTTPS git-receive-pack.

### Key Lesson

Always test direct connectivity FIRST when behind a proxy in China. The assumption "China = proxy required for GitHub" is often wrong for cloud VPS.
