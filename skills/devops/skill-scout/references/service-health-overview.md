# Known Service Health (this system)

## Hermes Agent Core
- Gateway: RUNNING - started May 13, PID 1865711, version v0.12.0
- WhatsApp Bridge: RUNNING - started May 11, node process

## Failed Services (long-standing, crash-loop)

### Clash-Meta Proxy (clash-meta.service)
- Status: systemd auto-restart, failed count in thousands
- Root cause: Configuration file at /etc/clash-meta/config.yaml is corrupted - contains garbled random content instead of valid YAML
- Log signature: Parse config error: yaml: unmarshal errors: line 1: cannot unmarshal !!str ... into config.RawConfig
- Impact: No proxy available. Does NOT affect Hermes Agent core.

### OpenClaw Gateway (openclaw-gateway.service)
- Status: systemd auto-restart, 24k+ restart counter
- Root cause: Missing configuration - Missing config. Run openclaw setup or set gateway.mode=local
- Log signature: Main process exited, code=exited, status=78/CONFIG
- Impact: OpenClaw CLI unavailable for gateway features. Hermes Agent runs independently.
- Fix: Either openclaw setup --allow-unconfigured or set gateway.mode=local in config.

## Security
- fail2ban: RUNNING
- SSH: public-facing, connection resets are normal
- No suspicious logins detected

## System Resources (as of 2026-05-14)
- Uptime: ~3 days
- Memory: 3.6Gi total, ~1.4Gi used (39%)
- Disk: 40G total, 21G used (56%)
- Load average: 0.45/0.35/0.25
