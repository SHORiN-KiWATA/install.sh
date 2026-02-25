#!/bin/bash
# ==============================================================================
# GRUB Theme Switcher & Themes Installer
# ==============================================================================

# --- Colors & Styles ---
NC='\033[0m'
BOLD='\033[1m'
H_GREEN='\033[1;32m'
H_YELLOW='\033[1;33m'
H_PURPLE='\033[1;35m'
H_CYAN='\033[1;36m'
H_RED='\033[1;31m'

# ------------------------------------------------------------------------------
# 0. Root Check & Auto-Elevation
# ------------------------------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
    # 如果脚本是以实体文件运行的，则自动寻求 sudo 权限重新执行
    if [ -f "$0" ]; then
        echo -e " ${H_YELLOW}⚠${NC} This script requires root privileges. Requesting via sudo..."
        exec sudo bash "$0" "$@"
    else
        # 如果脚本是通过 curl | bash 管道运行的，则提示正确的命令
        echo -e "\n ${H_RED}✘${NC} Root privileges required!"
        echo -e "   If you are piping this script via curl, please use ${H_CYAN}sudo bash${NC} instead of just ${H_CYAN}bash${NC}."
        echo -e "   Example: ${H_CYAN}curl -sL https://shorin.xyz/grub | sudo bash${NC}\n"
        exit 1
    fi
fi

echo -e "\n${H_PURPLE}╭────────────────────────────────────────────────────────╮${NC}"
echo -e "${H_PURPLE}│${NC}   ${BOLD}${H_CYAN}GRUB Theme Switcher Installer${NC}"
echo -e "${H_PURPLE}╰────────────────────────────────────────────────────────╯${NC}\n"

# ------------------------------------------------------------------------------
# 1. Download and Install the Switcher Script
# ------------------------------------------------------------------------------
echo -e " ${H_CYAN}➜${NC} Downloading 'change-grub-theme' script..."
SCRIPT_URL="https://raw.githubusercontent.com/SHORiN-KiWATA/shorin-arch-setup/refs/heads/main/resources/change-grub-theme"
BIN_PATH="/usr/local/bin/change-grub-theme"

if curl -sL "$SCRIPT_URL" -o "$BIN_PATH"; then
    chmod +x "$BIN_PATH"
    echo -e " ${H_GREEN}✔${NC} Installed successfully to $BIN_PATH"
else
    echo -e " ${H_RED}✘${NC} Failed to download the script from GitHub."
    echo -e "   Please check your network connection and try again."
    exit 1
fi

# ------------------------------------------------------------------------------
# 2. Clone Repository and Sync Themes
# ------------------------------------------------------------------------------
echo -e "\n ${H_CYAN}➜${NC} Fetching default themes from repository..."

if ! command -v git >/dev/null 2>&1; then
    echo -e " ${H_YELLOW}⚠${NC} 'git' is not installed. Skipping theme sync."
    echo -e "   You can still use the switcher for online themes (like Minegrub)."
else
    # Create a secure temporary directory
    TEMP_DIR=$(mktemp -d -t shorin_grub_installer_XXXXXX)
    
    # Use --depth 1 to make the clone extremely fast since we only need files, not history
    if git clone --depth 1 "https://github.com/SHORiN-KiWATA/shorin-arch-setup.git" "$TEMP_DIR" >/dev/null 2>&1; then
        DEST_DIR="/boot/grub/themes"
        mkdir -p "$DEST_DIR"
        
        echo -e " ${H_CYAN}➜${NC} Installing themes to $DEST_DIR..."
        
        # Sync only valid theme folders from the repo
        for dir in "$TEMP_DIR/grub-themes"/*; do
            if [ -d "$dir" ] && [ -f "$dir/theme.txt" ]; then
                THEME_BASENAME=$(basename "$dir")
                if [ ! -d "$DEST_DIR/$THEME_BASENAME" ]; then
                    cp -r "$dir" "$DEST_DIR/"
                    echo -e "   ${H_GREEN}+${NC} Added: $THEME_BASENAME"
                else
                    echo -e "   ${H_YELLOW}-${NC} Skipped: $THEME_BASENAME (Already exists)"
                fi
            fi
        done
        echo -e " ${H_GREEN}✔${NC} Themes synced."
    else
        echo -e " ${H_RED}✘${NC} Failed to clone the repository."
    fi

    # Clean up the temporary directory
    [ -n "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
    echo -e " ${H_GREEN}✔${NC} Temporary files cleaned up."
fi

# ------------------------------------------------------------------------------
# 3. Final Message
# ------------------------------------------------------------------------------
echo -e "\n${H_PURPLE}╭────────────────────────────────────────────────────────╮${NC}"
echo -e "${H_PURPLE}│${NC} ${BOLD}Installation Complete!${NC}"
echo -e "${H_PURPLE}│${NC} Run ${H_CYAN}sudo change-grub-theme${NC} anywhere to start."
echo -e "${H_PURPLE}╰────────────────────────────────────────────────────────╯${NC}\n"