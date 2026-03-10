#!/usr/bin/env bash
# OpenClaw 云服务器运维脚本
# 用法: openclaw.sh <command> [args]
#
# 配置: ~/.config/cloud-openclaw/config.sh

set -euo pipefail

# ============== 配置 ==============
CONFIG_FILE="${HOME}/.config/cloud-openclaw/config.sh"

# 默认值
CLOUD_HOST="${CLOUD_HOST:-}"
CLOUD_USER="${CLOUD_USER:-root}"
CLOUD_PORT="${CLOUD_PORT:-22}"
SSH_KEY_PATH="${SSH_KEY_PATH:-}"
OPENCLAW_PORT="${OPENCLAW_PORT:-18789}"
BROWSER_PORT="${BROWSER_PORT:-18791}"

# ============== 函数 ==============

# 加载配置
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    fi

    # 验证必要配置
    if [[ -z "$CLOUD_HOST" ]]; then
        echo "错误: 未配置 CLOUD_HOST"
        echo ""
        echo "请先配置 ~/.config/cloud-openclaw/config.sh"
        echo "参考: https://github.com/IsaacZhaoo/cloud-openclaw#1-首次配置"
        exit 1
    fi
}

# 构建 SSH 命令
build_ssh_cmd() {
    local cmd="$1"

    local ssh_cmd="ssh"

    # 添加端口
    if [[ "$CLOUD_PORT" != "22" ]]; then
        ssh_cmd="$ssh_cmd -p $CLOUD_PORT"
    fi

    # 添加密钥（如配置）
    if [[ -n "$SSH_KEY_PATH" ]]; then
        local expanded_key="${SSH_KEY_PATH/#\~/$HOME}"
        if [[ -f "$expanded_key" ]]; then
            ssh_cmd="$ssh_cmd -i '$expanded_key'"
        fi
    fi

    ssh_cmd="$ssh_cmd ${CLOUD_USER}@${CLOUD_HOST}"

    echo "$ssh_cmd '$cmd'"
}

# SSH 执行
ssh_exec() {
    local cmd="$1"
    local ssh_cmd
    ssh_cmd=$(build_ssh_cmd "$cmd")

    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo "[DEBUG] 执行: $ssh_cmd"
    fi

    eval "$ssh_cmd"
}

# 彩色输出
red() { echo -e "\033[31m$*\033[0m"; }
green() { echo -e "\033[32m$*\033[0m"; }
yellow() { echo -e "\033[33m$*\033[0m"; }
blue() { echo -e "\033[34m$*\033[0m"; }

# ============== 命令 ==============

# doctor - 健康检查（官方命令）
cmd_doctor() {
    echo "运行 OpenClaw 医生检查..."
    ssh_exec "openclaw doctor"
}

# health - 健康检查
cmd_health() {
    echo "检查 OpenClaw 健康状态..."
    ssh_exec "openclaw health"
}

# status - 状态检查
cmd_status() {
    echo "检查 OpenClaw 服务状态..."
    echo ""
    ssh_exec "systemctl --user status openclaw || systemctl status openclaw" || true

    echo ""
    echo "检查端口占用..."
    ssh_exec "ss -tlnp | grep -E '$OPENCLAW_PORT|$BROWSER_PORT'" || echo "端口未监听"
}

# status-deep - 深度状态
cmd_status_deep() {
    echo "深度检查 OpenClaw 状态..."
    ssh_exec "openclaw status --deep"
}

# start - 启动服务
cmd_start() {
    echo "启动 OpenClaw..."
    ssh_exec "systemctl --user start openclaw || sudo systemctl start openclaw"
    green "OpenClaw 已启动"
    cmd_status
}

# stop - 停止服务
cmd_stop() {
    echo "停止 OpenClaw..."
    ssh_exec "systemctl --user stop openclaw || sudo systemctl stop openclaw"
    green "OpenClaw 已停止"
}

# restart - 重启服务
cmd_restart() {
    echo "重启 OpenClaw..."
    ssh_exec "systemctl --user restart openclaw || sudo systemctl restart openclaw"
    green "OpenClaw 已重启"
    cmd_status
}

# logs - 查看日志（官方命令）
cmd_logs() {
    local lines="${1:-100}"
    local follow="${2:-}"

    if [[ "$follow" == "-f" ]]; then
        echo "查看实时日志（Ctrl+C 退出）..."
        ssh_exec "openclaw logs --follow"
    else
        echo "查看最近 $lines 行日志..."
        ssh_exec "openclaw logs -n $lines"
    fi
}

# logs-path - 查看日志文件位置
cmd_logs_path() {
    echo "日志文件位置: /tmp/openclaw/"
    ssh_exec "ls -la /tmp/openclaw/ 2>/dev/null || echo '日志目录不存在'"
}

# cleanup - 清理日志
cmd_cleanup() {
    local days="${1:-7}"
    echo "清理 $days 天前的日志..."

    ssh_exec "find /tmp/openclaw/ -name 'openclaw-*.log' -mtime +$days -delete 2>/dev/null || true"
    ssh_exec "find /tmp/openclaw-*.log -mtime +$days -delete 2>/dev/null || true"

    green "清理完成"
    echo ""
    cmd_disk
}

# disk - 磁盘检查
cmd_disk() {
    echo "磁盘使用情况:"
    ssh_exec "df -h /"
    echo ""
    echo "OpenClaw 目录大小:"
    ssh_exec "du -sh ~/.openclaw/ 2>/dev/null || echo '目录不存在'"
}

# memory - 内存检查
cmd_memory() {
    echo "内存使用情况:"
    ssh_exec "free -h"
    echo ""
    echo "OpenClaw 进程内存:"
    ssh_exec "ps aux --sort=-%mem | grep -E '[o]penclaw|[n]ode' | head -5"
}

# ports - 端口检查
cmd_ports() {
    echo "检查端口 $OPENCLAW_PORT 和 $BROWSER_PORT..."
    ssh_exec "ss -tlnp | grep -E '$OPENCLAW_PORT|$BROWSER_PORT'"
}

# process - 进程检查
cmd_process() {
    echo "OpenClaw 相关进程:"
    ssh_exec "ps aux | grep -E '[o]penclaw|[n]ode.*[g]ateway|[p]laywright' | grep -v grep"
}

# config - 查看配置
cmd_config() {
    echo "OpenClaw 配置 (前50行):"
    ssh_exec "cat ~/.openclaw/openclaw.json | head -50"
}

# version - 版本检查
cmd_version() {
    echo "OpenClaw 版本:"
    ssh_exec "openclaw --version 2>/dev/null || echo 'CLI 未安装'"
    echo ""
    echo "Node 版本:"
    ssh_exec "node --version"
}

# update - 更新
cmd_update() {
    local channel="${1:-stable}"
    echo "更新 OpenClaw ($channel)..."

    ssh_exec "openclaw update --channel $channel"

    green "更新完成，正在重启服务..."
    cmd_restart
}

# tunnel - SSH 隧道（本地执行）
cmd_tunnel() {
    if [[ -z "$CLOUD_HOST" ]]; then
        red "未配置 CLOUD_HOST"
        exit 1
    fi

    echo "创建 SSH 隧道到 $CLOUD_HOST..."
    echo "本地端口: $OPENCLAW_PORT -> 远程: 127.0.0.1:$OPENCLAW_PORT"
    echo "按 Ctrl+C 退出"
    echo ""

    local ssh_cmd="ssh"
    if [[ "$CLOUD_PORT" != "22" ]]; then
        ssh_cmd="$ssh_cmd -p $CLOUD_PORT"
    fi
    if [[ -n "$SSH_KEY_PATH" ]]; then
        local expanded_key="${SSH_KEY_PATH/#\~/$HOME}"
        ssh_cmd="$ssh_cmd -i '$expanded_key'"
    fi

    ssh_cmd="$ssh_cmd -N -L ${OPENCLAW_PORT}:127.0.0.1:${OPENCLAW_PORT} ${CLOUD_USER}@${CLOUD_HOST}"

    echo "执行: $ssh_cmd"
    eval "$ssh_cmd"
}

# remote - 远程命令（通过 SSH 隧道）
cmd_remote() {
    local subcmd="${1:-status}"
    shift

    echo "执行远程命令: openclaw $subcmd $*"
    ssh_exec "openclaw $subcmd $*"
}

# diag - 综合诊断
cmd_diag() {
    blue "========================================"
    blue "  OpenClaw 诊断报告"
    blue "========================================"
    echo ""

    # 服务状态
    yellow "1. 服务状态"
    echo "---"
    ssh_exec "systemctl --user is-active openclaw 2>/dev/null || systemctl is-active openclaw 2>/dev/null" && green "  运行中" || red "  已停止"
    echo ""

    # 端口
    yellow "2. 端口占用"
    echo "---"
    ssh_exec "ss -tlnp | grep -E '$OPENCLAW_PORT|$BROWSER_PORT'" || red "  端口未监听"
    echo ""

    # 版本
    yellow "3. 版本信息"
    echo "---"
    ssh_exec "openclaw --version 2>/dev/null || echo 'CLI 未安装'"
    echo ""

    # 最近错误
    yellow "4. 最近错误"
    echo "---"
    ssh_exec "openclaw logs -n 30 2>/dev/null | grep -i error" || echo "  无错误"
    echo ""

    # 磁盘
    yellow "5. 磁盘空间"
    echo "---"
    ssh_exec "df -h /"
    echo ""

    # 内存
    yellow "6. 内存使用"
    echo "---"
    ssh_exec "free -h"
    echo ""

    # 进程
    yellow "7. 相关进程"
    echo "---"
    ssh_exec "ps aux | grep -E '[o]penclaw|[n]ode' | head -5" || echo "  无进程"
    echo ""

    # Doctor 检查
    yellow "8. Doctor 检查"
    echo "---"
    ssh_exec "openclaw doctor 2>/dev/null" || echo "  Doctor 检查失败"
    echo ""

    blue "========================================"
    blue "  诊断完成"
    blue "========================================"
}

# help - 帮助
cmd_help() {
    cat << EOF
OpenClaw 云服务器运维脚本

用法: openclaw.sh <command> [参数]

=== 状态检查 ===
  status           查看服务状态
  status-deep      深度状态检查
  health           健康检查
  doctor           医生诊断（官方命令）
  version          版本信息

=== 服务管理 ===
  start            启动服务
  stop             停止服务
  restart          重启服务

=== 日志 ===
  logs [行数]      查看日志（默认100行）
  logs -f          实时跟踪日志
  logs-path        查看日志文件位置

=== 监控 ===
  ports            检查端口占用
  process          检查进程
  memory           检查内存
  disk             检查磁盘
  cleanup [天数]   清理日志（默认7天）

=== 配置 ===
  config           查看配置文件

=== 远程操作（通过 SSH 隧道）===
  tunnel           创建 SSH 隧道（本地执行）
  remote <cmd>     执行远程 openclaw 命令

=== 更新 ===
  update [stable|beta|dev]  更新版本

=== 诊断 ===
  diag             综合诊断（推荐用于排查问题）

=== 示例 ===
  openclaw.sh status           # 查看状态
  openclaw.sh logs -f         # 实时日志
  openclaw.sh diag            # 诊断问题
  openclaw.sh cleanup 14      # 清理14天前日志
  openclaw.sh remote status   # 远程执行 status

配置:
  配置文件: ~/.config/cloud-openclaw/config.sh

官方文档:
  https://docs.openclaw.ai
  https://github.com/openclaw/openclaw

EOF
}

# ============== 主程序 ==============

load_config

case "${1:-help}" in
    doctor)
        cmd_doctor
        ;;
    health)
        cmd_health
        ;;
    status)
        cmd_status
        ;;
    status-deep)
        cmd_status_deep
        ;;
    start)
        cmd_start
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    logs)
        cmd_logs "${2:-100}" "${3:-}"
        ;;
    logs-path)
        cmd_logs_path
        ;;
    cleanup)
        cmd_cleanup "${2:-7}"
        ;;
    disk)
        cmd_disk
        ;;
    memory)
        cmd_memory
        ;;
    ports)
        cmd_ports
        ;;
    process)
        cmd_process
        ;;
    config)
        cmd_config
        ;;
    version)
        cmd_version
        ;;
    update)
        cmd_update "${2:-stable}"
        ;;
    tunnel)
        cmd_tunnel
        ;;
    remote)
        shift
        cmd_remote "$@"
        ;;
    diag)
        cmd_diag
        ;;
    help|--help|-h)
        cmd_help
        ;;
    *)
        echo "未知命令: $1"
        echo ""
        cmd_help
        exit 1
        ;;
esac
