# OpenClaw 云服务管理工具

让 AI 帮你安装和运维 OpenClaw。不需要记命令，直接问 AI 就行。

## 解决什么问题

- 安装 OpenClaw 后不会运维？
- 每次出问题都要搜索、问人？
- 不想天天登录服务器？

这个工具帮你解决：遇到问题，直接问 AI。

## 安装

### 方式一：Claude Code Plugin 一键安装（推荐）

在 Claude Code 中运行：

```
/plugin marketplace add IsaacZhaoo/cloud-openclaw
/plugin install cloud-openclaw@cloud-openclaw-marketplace
```

安装后直接对 AI 说：
- 「帮我看看 OpenClaw 服务状态」
- 「最近日志有什么错误吗」
- 「帮我清理一下服务器」

### 方式二：手动安装到 Claude Code

```bash
git clone https://github.com/IsaacZhaoo/cloud-openclaw.git ~/.claude/skills/cloud-openclaw
```

### 方式三：直接给 AI 仓库链接

把仓库链接扔给你的 AI 助手，让它自己配置：

```
https://github.com/IsaacZhaoo/cloud-openclaw
```

## 前置要求

- 一台电脑（Mac/Windows/Linux）
- 能 SSH 登录你的云服务器
- AI 助手（Claude Code / Gemini CLI）

## 你能做什么

- 安装/更新 OpenClaw
- 查看服务状态和日志
- 重启服务、排查故障
- 清理磁盘、查看资源使用
- 设置 SSH 隧道远程访问

所有操作都通过自然语言，不需要记命令。

## FAQ

**Q: 需要记命令吗？**
A: 不需要。直接问 AI 就行。

**Q: 手机能用吗？**
A: 不能。需要电脑上的 AI CLI 工具。

**Q: 免费吗？**
A: 免费开源。

## 相关链接

- [OpenClaw 官方](https://github.com/openclaw/openclaw)
- [OpenClaw 文档](https://docs.openclaw.ai)
