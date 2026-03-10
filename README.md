# OpenClaw 一条龙指南：从安装到运维

让 AI 帮你安装和运维 OpenClaw。

## 一句话介绍

不需要记任何命令，直接问 AI 就行。

## 解决什么问题

- 安装 OpenClaw 后不会运维？
- 每次出问题都要搜索、问人？
- 不想天天登录服务器？

这个 Skill 帮你解决：遇到问题，直接问 AI。

## 特性

- ✅ **从安装到运维**：一条龙服务
- ✅ **不需要记命令**：说人话就行
- ✅ **AI 帮你干活**：安装、查看日志、重启服务、清理磁盘
- ✅ **小白友好**：不需要运维知识

## 快速开始

### 方法1：直接问 AI（推荐）

直接把仓库链接扔给你的 AI 助手：

```
https://github.com/IsaacZhaoo/cloud-openclaw
```

然后告诉它你想做什么：

- 「帮我安装 OpenClaw」
- 「帮我看看服务挂了没」
- 「最近日志有什么错误吗」
- 「帮我清理一下服务器」

AI 会自己配置、自己操作、自己帮你解决问题。

### 方法2：手动配置

```bash
# 1. 克隆仓库
git clone https://github.com/IsaacZhaoo/cloud-openclaw.git /tmp/cloud-openclaw

# 2. 复制脚本
cp /tmp/cloud-openclaw/scripts/openclaw.sh ~/openclaw.sh
chmod +x ~/openclaw.sh

# 3. 配置 SSH
# 创建 ~/.config/cloud-openclaw/config.sh，填入你的服务器信息

# 4. 使用
bash ~/openclaw.sh status    # 查看状态
bash ~/openclaw.sh diag     # 综合诊断
bash ~/openclaw.sh restart  # 重启服务
```

### 方法3：一键安装为 Claude Code Skill（推荐）

```bash
# 克隆到 Claude Code skills 目录
git clone https://github.com/IsaacZhaoo/cloud-openclaw.git ~/.claude/skills/cloud-openclaw
```

安装后，直接告诉 AI：
- 「帮我看看 OpenClaw 服务挂了没」
- 「最近日志有什么错误吗」
- 「帮我清理一下服务器」

AI 会自动使用这个 Skill 帮你操作服务器。

## 常用命令

| 命令 | 说明 |
|------|------|
| `status` | 查看服务状态 |
| `diag` | 综合诊断（推荐） |
| `logs` | 查看日志 |
| `restart` | 重启服务 |
| `cleanup` | 清理日志 |
| `disk` | 查看磁盘空间 |
| `memory` | 查看内存使用 |

## 前置要求

- 一台电脑（Mac/Windows/Linux）
- 能 SSH 登录服务器
- AI 助手（Claude Code / Gemini CLI）

## 常见问题

**Q: 需要记命令吗？**
A: 不需要。直接问 AI 就行。

**Q: 手机能用吗？**
A: 不能。需要电脑上的 AI CLI 工具。

**Q: 免费吗？**
A: 免费开源。

## 相关链接

- GitHub: https://github.com/IsaacZhaoo/cloud-openclaw
- OpenClaw 官方: https://github.com/openclaw/openclaw
- OpenClaw 文档: https://docs.openclaw.ai
