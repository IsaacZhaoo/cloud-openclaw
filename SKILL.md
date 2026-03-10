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

## 命令速查

| 命令 | 说明 | 备注 |
|------|------|------|
| `status` | 服务状态 + 端口检查 | |
| `status-deep` | 深度状态检查 | 官方命令 |
| `health` | 健康检查 | 官方命令 |
| `doctor` | 医生诊断 | 官方命令 |
| `version` | 版本信息 | |
| `start` | 启动服务 | |
| `stop` | 停止服务 | |
| `restart` | 重启服务 | |
| `logs [行数]` | 查看日志（默认100行） | |
| `logs -f` | 实时跟踪日志 | Ctrl+C 退出 |
| `logs-path` | 日志文件位置 | |
| `ports` | 端口占用 | |
| `process` | 进程列表 | |
| `memory` | 内存使用 | |
| `disk` | 磁盘空间 | |
| `cleanup [天数]` | 清理日志（默认7天） | |
| `config` | 查看配置文件 | |
| `tunnel` | 创建 SSH 隧道 | 本地执行 |
| `remote <cmd>` | 远程执行 openclaw 命令 | |
| `update [channel]` | 更新版本 | stable/beta/dev |
| `diag` | 综合诊断 | 推荐排障入口 |

## AI 驱动的故障排查流程

这是本 Skill 的核心价值：当用户报告 OpenClaw 出问题时，AI 可以自主排查。

### Step 1: 运行诊断

```bash
bash openclaw.sh diag
```

`diag` 会一次性检查：服务状态、端口、版本、最近错误、磁盘、内存、进程、Doctor。

### Step 2: 根据诊断结果判断问题类型

| 问题现象 | 可能原因 | 排查命令 | 解决方案 |
|----------|----------|----------|----------|
| 服务已停止 | 进程崩溃/端口占用/配置错误 | `logs`, `ports`, `config` | 修复后 `restart` |
| 服务运行但无法访问 | 防火墙/端口绑定/Gateway 异常 | `ports`, `logs` | 检查防火墙，`restart` |
| 认证/登录失败 | Token 过期/配置错误 | `doctor`, `logs` | 重新认证 |
| 响应很慢 | 磁盘空间不足/内存不足 | `disk`, `memory` | `cleanup` 清理 |
| 命令失败 | CLI 未安装/版本过旧 | `version` | `update` 更新 |

### Step 3: 深度排查

如果 Step 2 未解决问题，执行针对性命令：

```bash
# 查看最近错误日志
bash openclaw.sh logs 50    # 看最近50行

# 实时日志（观察运行时错误）
bash openclaw.sh logs -f

# 检查进程状态
bash openclaw.sh process

# 检查端口绑定
bash openclaw.sh ports

# 医生诊断（检查配置完整性）
bash openclaw.sh doctor
```

### Step 4: 常见修复操作

```bash
# 重启服务（解决大部分临时问题）
bash openclaw.sh restart

# 清理磁盘空间
bash openclaw.sh cleanup 14    # 清理14天前日志

# 更新版本
bash openclaw.sh update stable
```

## SSH 隧道（远程访问）

如果想从本地连接到云服务器上的 OpenClaw：

```bash
# 1. 创建 SSH 隧道
bash openclaw.sh tunnel

# 2. 另开终端，执行远程命令
bash openclaw.sh remote status
bash openclaw.sh remote health
```

隧道原理：`ssh -N -L 18789:127.0.0.1:18789 user@your-server`

## 故障排查参考

详细排障指南见 `references/troubleshooting.md`，包含：
- 常见错误及解决方案
- 日志分析方法
- 配置问题排查
- 网络问题排查

## 官方资源

- **GitHub 仓库**: https://github.com/openclaw/openclaw
- **官方文档**: https://docs.openclaw.ai
- **Gateway 文档**: https://docs.openclaw.ai/gateway

## 注意事项

1. **安全**：不要将包含真实密码/密钥的配置文件提交到 Git
2. **备份**：重要操作前建议备份 `~/.openclaw/openclaw.json`
3. **端口**：默认使用 18789（Gateway）和 18791（Browser Control）
4. **日志**：主要日志位置 `/tmp/openclaw/openclaw-YYYY-MM-DD.log`
