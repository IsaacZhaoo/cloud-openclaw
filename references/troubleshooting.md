# OpenClaw 故障排查指南

本文档为 AI 助手提供详细的故障排查流程和解决方案。基于官方文档：https://docs.openclaw.ai

## 快速诊断流程

当用户报告 OpenClaw 问题时，首先执行：

```bash
# 1. 运行综合诊断（推荐第一步）
bash openclaw.sh diag

# 2. 运行医生检查
bash openclaw.sh doctor

# 3. 查看最近错误
ssh $CLOUD_USER@$CLOUD_HOST "openclaw logs -n 50 | grep -i error"
```

## 官方 CLI 命令参考

OpenClaw 官方提供的 CLI 命令：

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

# Gateway 状态
openclaw gateway status

# 发送消息
openclaw message send --to +1234567890 --message "Hello"

# 对话助手
openclaw agent --message "你的问题"

# 更新
openclaw update --channel stable
```

## 常见问题及解决方案

### 1. 服务无法启动

**症状**: `systemctl start openclaw` 失败或立即退出

**排查步骤**:

```bash
# 查看详细启动日志
bash openclaw.sh logs

# 检查端口是否被占用
bash openclaw.sh ports

# 检查进程
bash openclaw.sh process

# 医生诊断
bash openclaw.sh doctor
```

**常见原因**:

| 错误信息 | 原因 | 解决方案 |
|----------|------|----------|
| `EADDRINUSE` | 端口 18789 被占用 | 找到占用进程并停止，或修改配置端口 |
| `ENOENT` | OpenClaw 目录不存在 | 重新安装 OpenClaw |
| `MODULE_NOT_FOUND` | 依赖未安装 | 运行 `npm install` 或重新安装 |

**解决方案**:

```bash
# 如果端口被占用，找到进程
ss -tlnp | grep 18789

# 停止占用进程
sudo kill <PID>

# 如果是旧进程残留
pkill -f '[n]ode.*openclaw'

# 重新启动
bash openclaw.sh restart
```

### 2. 无法访问 OpenClaw

**症状**: 无法通过浏览器访问 OpenClaw（通常端口 18789）

**排查步骤**:

```bash
# 检查服务状态
bash openclaw.sh status

# 检查端口监听
bash openclaw.sh ports

# 测试本地访问
ssh $CLOUD_USER@$CLOUD_HOST "curl -I http://localhost:18789"
```

**解决方案**:

```bash
# 如果服务已停止，启动服务
bash openclaw.sh start

# 如果端口未监听，检查服务日志
bash openclaw.sh logs

# 重启服务
bash openclaw.sh restart
```

### 3. 登录问题

**症状**: 无法登录网站或认证失败

**排查步骤**:

```bash
# 医生诊断
bash openclaw.sh doctor

# 检查日志中的认证错误
ssh $CLOUD_USER@$CLOUD_HOST "openclaw logs -n 50 | grep -i -E 'auth|login|token'"
```

**解决方案**:

登录问题通常需要：
1. 清除旧 cookies
2. 重新登录（通过浏览器手动登录）
3. 导出新的 cookies
4. 检查 Token 配置

### 4. 磁盘空间不足

**症状**: 服务响应缓慢或无法启动，提示空间不足

**排查步骤**:

```bash
# 检查磁盘空间
bash openclaw.sh disk

# 检查日志目录
bash openclaw.sh logs-path
```

**解决方案**:

```bash
# 清理日志（默认 7 天前）
bash openclaw.sh cleanup

# 或手动清理
ssh $CLOUD_USER@$CLOUD_HOST "find /tmp/openclaw/ -name 'openclaw-*.log' -mtime +7 -delete"
```

### 5. 内存不足

**症状**: 服务崩溃或无响应

**排查步骤**:

```bash
# 查看内存使用
bash openclaw.sh memory

# 查看进程内存
ssh $CLOUD_USER@$CLOUD_HOST "ps aux --sort=-%mem | head -10"
```

**解决方案**:

```bash
# 重启服务释放内存
bash openclaw.sh restart
```

### 6. CLI 命令失败

**症状**: `openclaw` 命令不存在或报错

**排查步骤**:

```bash
# 检查版本
bash openclaw.sh version

# 检查 Node.js
ssh $CLOUD_USER@$CLOUD_HOST "node --version"
```

**解决方案**:

```bash
# 重新安装 CLI
ssh $CLOUD_USER@$CLOUD_HOST "npm install -g openclaw@latest"

# 或使用 pnpm
ssh $CLOUD_USER@$CLOUD_HOST "pnpm add -g openclaw@latest"
```

### 7. 远程访问问题

**症状**: 无法通过 SSH 隧道访问远程 OpenClaw

**排查步骤**:

```bash
# 检查本地隧道
# 确保 SSH 隧道已建立
ssh -N -L 18789:127.0.0.1:18789 user@your-server

# 然后测试
bash openclaw.sh remote health
```

## 日志分析方法

### 日志位置

```
# 默认日志位置（官方）
/tmp/openclaw/openclaw-YYYY-MM-DD.log

# 实时查看
openclaw logs --follow

# 查看最近 N 行
openclaw logs -n 100
```

### 日志级别

在 `~/.openclaw/openclaw.json` 中配置：

```json
{
  "logging": {
    "level": "debug",
    "consoleLevel": "info"
  }
}
```

级别：`trace` > `debug` > `info` > `warn` > `error`

### 常见日志关键词

| 关键词 | 含义 |
|--------|------|
| `ERROR` | 错误，需要关注 |
| `WARN` | 警告，可能有问题 |
| `panic` | 严重错误，服务崩溃 |
| `timeout` | 超时，可能是网络问题 |
| `ECONNREFUSED` | 连接被拒绝，服务未启动 |
| `EADDRINUSE` | 端口被占用 |

### 日志分析示例

```bash
# 查看错误
ssh $CLOUD_USER@$CLOUD_HOST "openclaw logs -n 100 | grep -i error"

# 查看警告
ssh $CLOUD_USER@$CLOUD_HOST "openclaw logs -n 100 | grep -i warn"

# 查看特定时间段
ssh $CLOUD_USER@$CLOUD_HOST "openclaw logs | grep '2024-01-01'"
```

## 配置问题排查

### 配置文件位置

```
~/.openclaw/openclaw.json
```

### 验证配置语法

```bash
# 备份配置
ssh $CLOUD_USER@$CLOUD_HOST "cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak"

# 检查 JSON 语法
ssh $CLOUD_USER@$CLOUD_HOST "cat ~/.openclaw/openclaw.json | python3 -m json.tool > /dev/null && echo 'JSON 语法正确'"
```

### 医生检查

```bash
# 运行官方 doctor 命令
bash openclaw.sh doctor
```

这会检查：
- 配置问题
- 风险设置
- DM 策略问题

## 官方文档链接

- **GitHub**: https://github.com/openclaw/openclaw
- **官方文档**: https://docs.openclaw.ai
- **Gateway 文档**: https://docs.openclaw.ai/gateway
- **远程访问**: https://docs.openclaw.ai/gateway/remote
- **日志文档**: https://docs.openclaw.ai/gateway/logging
- **安全指南**: https://docs.openclaw.ai/gateway/security

## 急救命令

当所有方法都失效时，尝试：

```bash
# 1. 完全重启服务
bash openclaw.sh stop
sleep 2
bash openclaw.sh start

# 2. 如果还是不行，查看完整日志
bash openclaw.sh logs -f

# 3. 查看系统日志
ssh $CLOUD_USER@$CLOUD_HOST "journalctl --user -u openclaw -n 50"

# 4. 检查系统状态
bash openclaw.sh diag
```

## 何时寻求帮助

如果以下情况，请提供详细信息寻求帮助：

1. 错误信息不明确
2. 无法定位问题
3. 需要重新安装

**提供的信息**：
- `bash openclaw.sh diag` 的完整输出
- `bash openclaw.sh doctor` 的输出
- `bash openclaw.sh logs -n 50` 的错误部分
- 错误发生前的操作
- 服务器系统信息：`uname -a`
