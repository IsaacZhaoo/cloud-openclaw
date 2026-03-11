---
name: cloud-openclaw
description: Manage OpenClaw services on remote cloud servers via SSH. From installation to operations — full lifecycle support. No commands to memorize, just ask AI. Designed for users without server administration experience.
---

# OpenClaw Operations Skill

This Skill helps AI manage OpenClaw services on remote cloud servers via SSH.

## When to Use

Use this Skill when the user requests:

- First-time OpenClaw installation
- Starting / stopping / restarting OpenClaw services
- Viewing logs to troubleshoot issues
- Cleaning up temp files to free disk space
- Diagnosing service failures

## Prerequisites

Before running any operation, verify:

1. **SSH config**: Check if `~/.config/cloud-openclaw/config.sh` exists
2. **Script availability**: Confirm `~/openclaw.sh` is present and executable

If the config doesn't exist, guide the user to create it:

```bash
mkdir -p ~/.config/cloud-openclaw
cat > ~/.config/cloud-openclaw/config.sh << 'EOF'
export CLOUD_HOST="server-ip"
export CLOUD_USER="root"
export CLOUD_PORT="22"
EOF
```

## Command Reference

| Action | Command |
|--------|---------|
| Check status | `bash openclaw.sh status` |
| Full diagnosis | `bash openclaw.sh diag` |
| View logs | `bash openclaw.sh logs` |
| Restart service | `bash openclaw.sh restart` |
| Clean up disk | `bash openclaw.sh cleanup` |
| Check disk usage | `bash openclaw.sh disk` |
| Check memory | `bash openclaw.sh memory` |

## Troubleshooting Workflow

When a user reports an OpenClaw problem, follow these steps:

### Step 1: Run Full Diagnosis

```bash
bash openclaw.sh diag
```

Checks: service status, ports, version, recent errors, disk, memory, processes, Doctor

### Step 2: Identify the Problem

| Symptom | Possible Cause | Commands |
|---------|---------------|----------|
| Service stopped | Process crash / port conflict / config error | `logs`, `ports`, `config` |
| Running but unreachable | Firewall / port binding / gateway issue | `ports`, `logs` |
| Auth/login failure | Expired token / config error | `doctor`, `logs` |
| Slow response | Low disk space / low memory | `disk`, `memory` |

### Step 3: Deep Investigation

```bash
# Recent logs
bash openclaw.sh logs 50

# Live log stream
bash openclaw.sh logs -f

# Check processes
bash openclaw.sh process

# Check ports
bash openclaw.sh ports

# Doctor diagnosis
bash openclaw.sh doctor
```

### Step 4: Fix

```bash
# Restart service
bash openclaw.sh restart

# Clean logs older than 14 days
bash openclaw.sh cleanup 14

# Update to stable version
bash openclaw.sh update stable
```

## SSH Tunnel

For local access to remote OpenClaw:

```bash
# Create tunnel
bash openclaw.sh tunnel

# Remote commands
bash openclaw.sh remote status
bash openclaw.sh remote health
```

## Detailed Reference

See `references/troubleshooting.md` for the full troubleshooting guide.

## Resources

- OpenClaw Official: https://github.com/openclaw/openclaw
- OpenClaw Docs: https://docs.openclaw.ai

---

# OpenClaw 运维 Skill

本 Skill 帮助 AI 通过 SSH 管理远程云服务器上的 OpenClaw 服务。

## 适用场景

当用户请求以下操作时，使用本 Skill：

- 第一次安装 OpenClaw
- 启动/停止/重启 OpenClaw 服务
- 查看运行日志排查问题
- 清理临时文件释放空间
- 排查服务故障

## 前置检查

在执行任何操作前，验证以下条件：

1. **SSH 配置**：检查 `~/.config/cloud-openclaw/config.sh` 是否存在
2. **脚本可用性**：确认 `~/openclaw.sh` 脚本存在且可执行

如果配置不存在，引导用户创建：

```bash
mkdir -p ~/.config/cloud-openclaw
cat > ~/.config/cloud-openclaw/config.sh << 'EOF'
export CLOUD_HOST="服务器IP"
export CLOUD_USER="root"
export CLOUD_PORT="22"
EOF
```

## 核心命令速查

| 操作 | 命令 |
|------|------|
| 查看状态 | `bash openclaw.sh status` |
| 综合诊断 | `bash openclaw.sh diag` |
| 查看日志 | `bash openclaw.sh logs` |
| 重启服务 | `bash openclaw.sh restart` |
| 清理磁盘 | `bash openclaw.sh cleanup` |
| 查看磁盘 | `bash openclaw.sh disk` |
| 查看内存 | `bash openclaw.sh memory` |

## 故障排查流程

当用户报告 OpenClaw 出问题时，按以下步骤排查：

### Step 1: 运行综合诊断

```bash
bash openclaw.sh diag
```

诊断检查项：服务状态、端口、版本、最近错误、磁盘、内存、进程、Doctor

### Step 2: 分析问题类型

| 问题现象 | 可能原因 | 排查命令 |
|----------|----------|----------|
| 服务已停止 | 进程崩溃/端口占用/配置错误 | `logs`, `ports`, `config` |
| 服务运行但无法访问 | 防火墙/端口绑定/Gateway 异常 | `ports`, `logs` |
| 认证/登录失败 | Token 过期/配置错误 | `doctor`, `logs` |
| 响应很慢 | 磁盘空间不足/内存不足 | `disk`, `memory` |

### Step 3: 深度排查命令

```bash
# 查看最近日志
bash openclaw.sh logs 50

# 实时日志
bash openclaw.sh logs -f

# 检查进程
bash openclaw.sh process

# 检查端口
bash openclaw.sh ports

# 医生诊断
bash openclaw.sh doctor
```

### Step 4: 修复操作

```bash
# 重启服务
bash openclaw.sh restart

# 清理14天前日志
bash openclaw.sh cleanup 14

# 更新版本
bash openclaw.sh update stable
```

## SSH 隧道

如需本地访问远程 OpenClaw：

```bash
# 创建隧道
bash openclaw.sh tunnel

# 远程执行命令
bash openclaw.sh remote status
bash openclaw.sh remote health
```

## 详细参考

详细排障指南见 `references/troubleshooting.md`

## 官方资源

- OpenClaw 官方: https://github.com/openclaw/openclaw
- OpenClaw 文档: https://docs.openclaw.ai
