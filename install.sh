#!/usr/bin/env bash
# ==============================================================================
#  DDreamer01's Dotfiles Installer
#  Hyprland Rice (Last Horizon / Obsidian Minimalist)
# ==============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${BOLD}${BLUE}=== Installing DDreamer01's Hyprland Dotfiles ===${RESET}\n"

# 1. Check dependencies
echo -e "${YELLOW}--> Checking core dependencies...${RESET}"
DEPS=(hyprland waybar rofi swaync hyprlock hypridle hyprpaper kitty grim slurp wl-copy brightnessctl wpctl)
MISSING=()

for dep in "${DEPS[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
        MISSING+=("$dep")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo -e "${YELLOW}[!] Warning: The following packages were not found in PATH:${RESET}"
    echo -e "    ${MISSING[*]}"
    echo -e "    Install them via your package manager (e.g. apt / pacman / dnf) for full functionality.\n"
else
    echo -e "${GREEN}[✓] All core dependencies found!${RESET}\n"
fi

# 2. Backup existing configurations
CONFIGS=(hypr waybar rofi swaync kitty)
NEEDS_BACKUP=0

for cfg in "${CONFIGS[@]}"; do
    if [ -e "$CONFIG_DIR/$cfg" ] && [ ! -L "$CONFIG_DIR/$cfg" ]; then
        NEEDS_BACKUP=1
        break
    fi
done

if [ $NEEDS_BACKUP -eq 1 ]; then
    echo -e "${YELLOW}--> Backing up existing configurations to ${BACKUP_DIR}...${RESET}"
    mkdir -p "$BACKUP_DIR"
    for cfg in "${CONFIGS[@]}"; do
        if [ -e "$CONFIG_DIR/$cfg" ] && [ ! -L "$CONFIG_DIR/$cfg" ]; then
            cp -r "$CONFIG_DIR/$cfg" "$BACKUP_DIR/"
            echo -e "    Backed up: $CONFIG_DIR/$cfg"
        fi
    done
    echo -e "${GREEN}[✓] Backup completed.${RESET}\n"
fi

# 3. Deploy configurations (Symlink mode)
echo -e "${BLUE}--> Deploying configuration symlinks...${RESET}"
mkdir -p "$CONFIG_DIR"

for cfg in "${CONFIGS[@]}"; do
    TARGET="$CONFIG_DIR/$cfg"
    SOURCE="$DOTFILES_DIR/.config/$cfg"

    if [ -d "$SOURCE" ]; then
        rm -rf "$TARGET"
        ln -sf "$SOURCE" "$TARGET"
        echo -e "    ${GREEN}[✓] Linked:${RESET} $TARGET -> $SOURCE"
    fi
done

# 4. Ensure script executable permissions
echo -e "\n${BLUE}--> Setting executable permissions on scripts...${RESET}"
chmod +x "$DOTFILES_DIR"/.config/hypr/scripts/*.sh 2>/dev/null || true
chmod +x "$DOTFILES_DIR"/.config/waybar/*.sh 2>/dev/null || true
echo -e "${GREEN}[✓] Script permissions set.${RESET}\n"

echo -e "${BOLD}${GREEN}=== Installation Complete! ===${RESET}"
echo -e "Reload your session or restart Hyprland:"
echo -e "  • Hyprland: hyprctl reload"
echo -e "  • Waybar:   systemctl --user restart waybar"
echo -e "  • SwayNC:   swaync-client -R && swaync-client -rs"
echo -e "  • Hypridle: systemctl --user restart hypridle\n"
