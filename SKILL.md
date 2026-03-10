---
name: cloud-openclaw
description: 通过 SSH 管理远程云服务器上的 OpenClaw 服务。适用于需要在云服务器上部署、启动、停止、查看日志、清理等运维操作。支持用户自定义 SSH 连接信息，适合不具备复杂运维知识的小白用户。
---

# 云服务器 OpenClaw 运维 Skill

本 Skill 帮助用户（和 AI 助手如 Claude/Gemini）通过简单的命令管理远程云服务器上的 OpenClaw 服务。

## 适用场景

- 远程部署 OpenClaw 到云服务器
- 启动/停止/重启 OpenClaw 服务
- 查看运行日志排查问题
- 清理临时文件释放空间
- 排查服务故障（核心场景）

## 前置要求

1. **SSH 访问权限**：能连接到你的云服务器
2. **SSH 密钥**：建议使用密钥登录（可选）
3. **云服务器已安装 OpenClaw**：
   - 官方安装指南：https://github.com/openclaw/openclaw#installation
   - 或使用一键安装：`openclaw onboard --install-daemon`

## 快速开始

### 1. 首次配置

```bash
# 创建配置目录
mkdir -p ~/.config/cloud-openclaw

# 创建配置文件（替换为你的实际值）
cat > ~/.config/cloud-openclaw/config.sh << 'EOF'
# 云服务器连接信息
export CLOUD_HOST="你的服务器IP或域名"
export CLOUD_USER="你的SSH用户名"
export CLOUD_PORT="22"

# 可选：SSH 密钥路径
# export SSH_KEY_PATH="$HOME/.ssh/id_rsa"

# OpenClaw 配置（默认）
export OPENCLAW_PORT="18789"
export BROWSER_PORT="18791"
EOF
```

### 2. 基本命令

```bash
# 查看服务状态（推荐第一步）
bash openclaw.sh status

# 综合诊断（排查问题）
bash openclaw.sh diag

# 查看日志
bash openclaw.sh logs

# 启动/重启
bash openclaw.sh start
bash openclaw.sh restart
```

## 命令详解

### 状态检查

| 命令 | 说明 | 官方命令 |
|------|------|----------|
| `status` | 查看服务状态和端口 | - |
| `status-deep` | 深度状态检查 | `openclaw status --deep` |
| `health` | 健康检查 | `openclaw health` |
| `doctor` | 医生诊断 | `openclaw doctor` |
| `version` | 版本信息 | `openclaw --version` |

### 服务管理

| 命令 | 说明 |
|------|------|
| `start` | 启动服务 |
| `stop` | 停止服务 |
| `restart` | 重启服务 |

### 日志查看

| 命令 | 说明 | 官方命令 |
|------|------|----------|
| `logs` | 查看最近 N 行日志 | `openclaw logs -n N` |
| `logs -f` | 实时跟踪日志 | `openclaw logs --follow` |
| `logs-path` | 查看日志文件位置 | `/tmp/openclaw/` |

### 监控

| 命令 | 说明 |
|------|------|
| `ports` | 检查端口占用 |
| `process` | 检查进程 |
| `memory` | 检查内存使用 |
| `disk` | 检查磁盘空间 |

### 维护

| 命令 | 说明 |
|------|------|
| `cleanup [天数]` | 清理日志（默认7天） |
| `config` | 查看配置文件 |

### 远程操作

| 命令 | 说明 |
|------|------|
| `tunnel` | 创建 SSH 隧道到云服务器 |
| `remote <cmd>` | 通过隧道执行 openclaw 命令 |

### 更新

| 命令 | 说明 |
|------|------|
| `update [channel]` | 更新到 stable/beta/dev 频道 |

## AI 驱动的故障排查流程

当用户报告 OpenClaw 出问题时，按以下流程排查：

### Step 1: 运行诊断命令

```bash
bash openclaw.sh diag
```

### Step 2: 根据诊断结果处理

**情况 A: 服务已停止**
```
可能原因：
1. 进程崩溃 → 检查日志: logs
2. 端口被占用 → 检查: ports
3. 配置文件错误 → 检查: config

处理：
- 查看日志定位错误
- 如果端口被占用，查找占用进程并停止
- 如果配置错误，修复后重启
```

**情况 B: 服务运行但无法访问**
```
可能原因：
1. 防火墙阻止 → 检查: ports
2. 端口绑定错误 → 检查: ports
3. Gateway 未正常启动

处理：
- 检查端口绑定
- 查看日志中的错误
- 重启服务
```

**情况 C: 认证/登录问题**
```
可能原因：
1. Token 过期
2. 配置文件错误

处理：
- 运行 doctor 检查
- 查看日志中的认证错误
```

### Step 3: 常用排障命令

AI 可以直接执行以下命令进行排查：

```bash
# 查看服务状态
bash openclaw.sh status

# 综合诊断（推荐）
bash openclaw.sh diag

# 查看实时日志
bash openclaw.sh logs -f

# 查看最近错误
ssh $CLOUD_USER@$CLOUD_HOST "openclaw logs -n 50 | grep -i error"

# 健康检查
bash openclaw.sh health

# 医生诊断
bash openclaw.sh doctor

# 检查端口
bash openclaw.sh ports

# 检查进程
bash openclaw.sh process
```

### Step 4: 常见问题速查

| 问题现象 | 可能原因 | 解决命令 |
|----------|----------|----------|
| 服务启动失败 | 端口被占用 | `logs` 查看错误，`restart` 重启 |
| 无法访问 | 防火墙/端口未监听 | `ports` 检查，`restart` 重启 |
| 响应很慢 | 磁盘空间不足 | `disk` 检查，`cleanup` 清理 |
| 登录失败 | Token 过期 | `doctor` 检查，`config` 查看 |
| 命令失败 | 未安装 | `version` 检查 |

## 官方 OpenClaw CLI 命令

本 Skill 封装了以下官方命令，完整 CLI 参考：https://docs.openclaw.ai

```bash
# 健康检查
openclaw health

# 医生诊断（检查配置问题）
openclaw doctor

# 查看日志
openclaw logs --follow
openclaw logs -n 100

# 深度状态
openclaw status --deep

# 更新
openclaw update --channel stable

# 启动 Gateway
openclaw gateway --port 18789 --verbose

# 发送消息
openclaw message send --to +1234567890 --message "Hello"

# 对话助手
openclaw agent --message "你的问题"
```

## SSH 隧道（远程访问）

如果想从本地连接到云服务器上的 OpenClaw：

```bash
# 1. 创建 SSH 隧道
bash openclaw.sh tunnel

# 2. 另开终端，执行远程命令
bash openclaw.sh remote status
bash openclaw.sh remote health
bash openclaw.sh remote agent --message "你好"
```

SSH 隧道命令原理：
```bash
ssh -N -L 18789:127.0.0.1:18789 user@your-server
```

## 官方资源

- **GitHub 仓库**: https://github.com/openclaw/openclaw
- **官方文档**: https://docs.openclaw.ai
- **Gateway 文档**: https://docs.openclaw.ai/gateway
- **远程访问**: https://docs.openclaw.ai/gateway/remote
- **日志文档**: https://docs.openclaw.ai/gateway/logging

## 故障排查参考

详细排障指南见 `references/troubleshooting.md`，包含：
- 常见错误及解决方案
- 日志分析方法
- 配置问题排查
- 网络问题排查

## 文件结构

```
cloud-openclaw/
├── SKILL.md                    # 本文件
├── scripts/
│   └── openclaw.sh             # 核心运维脚本
└── references/
    └── troubleshooting.md       # 排障指南
```

## 注意事项

1. **安全**：不要将包含真实密码/密钥的配置文件提交到 Git
2. **备份**：重要操作前建议备份 `~/.openclaw/openclaw.json`
3. **端口**：默认使用 18789（Gateway）和 18791（Browser Control）
4. **日志**：主要日志位置 `/tmp/openclaw/openclaw-YYYY-MM-DD.log`
