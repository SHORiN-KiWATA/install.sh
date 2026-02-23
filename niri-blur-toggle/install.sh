#!/usr/bin/env bash

# 开启严格模式
set -euo pipefail

# ==========================================
# 变量定义
# ==========================================
RAW_URL="https://raw.githubusercontent.com/SHORiN-KiWATA/install.sh/refs/heads/main/niri-blur-toggle/niri-blur-toggle"
DEST_DIR="${HOME}/.local/bin"
DEST_FILE="${DEST_DIR}/niri-blur-toggle"

# 颜色定义
GREEN='\e[1;32m'
BLUE='\e[1;34m'
YELLOW='\e[1;33m'
RED='\e[1;31m'
NC='\e[0m' # 重置颜色

info()    { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[+]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]$1${NC}"; }

echo -e "\n${BLUE}======================================${NC}"
echo -e "${GREEN}  Niri Blur Toggle 安装向导${NC}"
echo -e "${BLUE}======================================${NC}\n"

# 1. 确保目标目录存在
info "检查目标目录 ${DEST_DIR}..."
mkdir -p "$DEST_DIR"

# 2. 拉取脚本
info "正在从 GitHub 下载脚本..."
# curl 参数说明:
# -f: 遇到 HTTP 错误 (如 404) 时直接失败并返回非 0 状态码
# -s: 静默模式，不显示进度条
# -S: 如果发生错误，显示错误信息
# -L: 跟随重定向
curl -fsSL "$RAW_URL" -o "$DEST_FILE"

# 3. 赋予执行权限
info "配置执行权限..."
chmod +x "$DEST_FILE"

# 4. 检查环境变量 PATH (简单检测)
if [[ ":$PATH:" != *":$DEST_DIR:"* ]]; then
    echo ""
    warning " ⚠️  注意: 目标目录不在你的 PATH 环境变量中！"
    warning " 你的终端可能无法直接识别 niri-blur-toggle 命令。"
    warning " 请将 ${DEST_DIR} 添加到你的 shell 配置文件 (如 ~/.config/fish/config.fish 或 ~/.bashrc) 中。"
fi

# 5. 打印完成信息和使用指南
echo ""
success "安装成功！"
echo -e "脚本已部署至: ${GREEN}${DEST_FILE}${NC}\n"

echo -e "你可以直接在终端运行以下命令："
echo -e "  ${GREEN}niri-blur-toggle${NC}         ${BLUE}# 在 Stable 和 Blur 测试版之间无缝切换${NC}"
echo -e "  ${GREEN}niri-blur-toggle update${NC}  ${BLUE}# 获取最新 wip/branch 源码并智能编译更新${NC}\n"
