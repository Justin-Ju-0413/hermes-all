# Hermes All — 跨设备初始化配置库

快速在新设备上初始化 Hermes Agent 的配置集合。

## 包含内容

- `config.yaml` — 核心配置
- `skills/` — 所有技能（不含 node_modules）
- `cron/` — 定时任务配置 + 执行记录
- `SOUL.md` — 灵魂设定
- `scripts/` — 工具脚本
- `.gitignore` — 忽略规则

## 不包含（运行时数据，不同设备不同）

- `state.db*` — 状态数据库
- `sessions/` — 会话历史
- `memories/` — 持久记忆
- `models_dev_cache.json` — 模型缓存
- `node_modules/` — npm 依赖

## 使用方式

```bash
# 在新服务器上
git clone https://github.com/Justin-Ju-0413/hermes-all.git ~/.hermes/
# 然后运行 hermes setup 初始化
```

## 自动备份

`scripts/backup.sh` 将 `~/.hermes/` 中的配置同步到此仓库并推送到 GitHub。
由 cron 任务 "GitHub Sync" 每 3 小时自动执行。
