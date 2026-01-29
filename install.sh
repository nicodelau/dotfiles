#!/bin/bash

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃              Dotfiles Installer - Plug & Play                ┃
# ┃         Symlinks configs + installs dev tools                ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[x]${NC} $1"; }
section() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

# ── Backup existing config if it's not already a symlink ──────────
backup_and_link() {
    local src="$1"
    local dest="$2"

    # If dest is already a symlink pointing to src, skip
    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
        info "Already linked: $dest"
        return
    fi

    # If dest exists (file, dir, or different symlink), back it up
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP_DIR"
        warn "Backing up: $dest -> $BACKUP_DIR/"
        mv "$dest" "$BACKUP_DIR/"
    fi

    ln -sf "$src" "$dest"
    info "Linked: $src -> $dest"
}

# ── Create required directories ───────────────────────────────────
section "Creating directories"
mkdir -p "$CONFIG"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/Pictures"

# ── Symlink config directories ────────────────────────────────────
section "Linking config directories"

CONFIG_DIRS=(
    "hypr"
    "nvim"
    "rofi"
    "dunst"
    "eww"
    "kitty"
)

for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$DOTFILES/$dir" ]; then
        backup_and_link "$DOTFILES/$dir" "$CONFIG/$dir"
    else
        warn "Directory not found: $DOTFILES/$dir (skipping)"
    fi
done

# ── Symlink individual config files ──────────────────────────────
section "Linking config files"

if [ -f "$DOTFILES/mimeapps.list" ]; then
    backup_and_link "$DOTFILES/mimeapps.list" "$CONFIG/mimeapps.list"
fi

# ── Symlink wallpapers ────────────────────────────────────────────
section "Linking wallpapers"

if [ -d "$DOTFILES/wallpapers" ]; then
    backup_and_link "$DOTFILES/wallpapers" "$HOME/Pictures/wallpapers"
fi

# ── Install SDDM theme (requires sudo) ───────────────────────────
section "SDDM Theme"

SDDM_THEME_DIR="/usr/share/sddm/themes/liquid-glass"
SDDM_CONF_DIR="/etc/sddm.conf.d"

if [ -d "$DOTFILES/sddm/liquid-glass" ]; then
    echo -e "Install Liquid Glass SDDM theme? (requires sudo) [y/N] "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        sudo mkdir -p "$SDDM_THEME_DIR"
        sudo cp -rf "$DOTFILES/sddm/liquid-glass/"* "$SDDM_THEME_DIR/"
        sudo mkdir -p "$SDDM_CONF_DIR"
        sudo cp -f "$DOTFILES/sddm/sddm.conf" "$SDDM_CONF_DIR/liquid-glass.conf"
        info "SDDM Liquid Glass theme installed"
        info "Enable SDDM with: sudo systemctl enable sddm"
    else
        warn "Skipping SDDM theme installation"
    fi
else
    warn "SDDM theme not found in $DOTFILES/sddm/"
fi

# ── Install development tools ─────────────────────────────────────
section "Development tools"

install_if_missing() {
    local cmd="$1"
    local pkg="$2"

    if command -v "$cmd" &>/dev/null; then
        info "$cmd already installed ($(command -v "$cmd"))"
    else
        warn "$cmd not found. Installing $pkg..."
        if command -v paru &>/dev/null; then
            paru -S --noconfirm "$pkg"
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm "$pkg"
        else
            error "No compatible package manager found. Install $pkg manually."
            return 1
        fi
        info "$cmd installed successfully"
    fi
}

install_if_missing "go"      "go"
install_if_missing "node"    "nodejs"
install_if_missing "npm"     "npm"
install_if_missing "lazygit" "lazygit"

# ── Copy utility scripts to local bin ─────────────────────────────
section "Utility scripts"

for script in "$DOTFILES"/scripts/*.sh; do
    if [ -f "$script" ]; then
        name="$(basename "$script" .sh)"
        cp "$script" "$HOME/.local/bin/$name"
        chmod +x "$HOME/.local/bin/$name"
        info "Installed script: $name"
    fi
done

# ── Summary ───────────────────────────────────────────────────────
section "Done"

echo ""
info "Dotfiles installed successfully!"
if [ -d "$BACKUP_DIR" ]; then
    warn "Previous configs backed up to: $BACKUP_DIR"
fi
echo ""
info "Next steps:"
info "  1. Run ./setup.sh if you haven't installed dependencies yet"
info "  2. Restart your session or reboot"
info "  3. Press Super+L to test hyprlock"
echo ""
