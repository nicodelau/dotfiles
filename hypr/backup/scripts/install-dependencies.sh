#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃         Liquid Glass - Dependency Installer                  ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║           Liquid Glass - Installing Dependencies           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please run without sudo. The script will ask for password when needed."
    exit 1
fi

# Function to install packages
install_packages() {
    echo -e "${BLUE}[1/4]${NC} Updating system..."
    sudo pacman -Syu --noconfirm

    echo -e "${BLUE}[2/4]${NC} Installing official packages..."
    sudo pacman -S --needed --noconfirm \
        rofi-wayland \
        playerctl \
        brightnessctl \
        libnotify \
        wl-clipboard \
        socat \
        jq \
        imagemagick \
        lua \
        git \
        base-devel

    echo -e "${GREEN}✓${NC} Official packages installed"
}

# Function to install paru (AUR helper)
install_paru() {
    if command -v paru &> /dev/null; then
        echo -e "${GREEN}✓${NC} paru already installed"
        return
    fi

    echo -e "${BLUE}[3/4]${NC} Installing paru (AUR helper)..."
    cd /tmp
    rm -rf paru
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/paru

    echo -e "${GREEN}✓${NC} paru installed"
}

# Function to install AUR packages
install_aur_packages() {
    echo -e "${BLUE}[4/4]${NC} Installing AUR packages..."

    paru -S --needed --noconfirm \
        eww \
        awww \
        cliphist

    echo -e "${GREEN}✓${NC} AUR packages installed"
}

# Function to setup fonts
setup_fonts() {
    echo ""
    echo "Installing fonts..."

    # SF Pro Display (if available) or Inter as fallback
    sudo pacman -S --needed --noconfirm \
        inter-font \
        ttf-jetbrains-mono-nerd \
        papirus-icon-theme

    echo -e "${GREEN}✓${NC} Fonts installed"
}

# Function to create wallpaper directory with sample
setup_wallpapers() {
    echo ""
    echo "Setting up wallpaper directory..."

    mkdir -p ~/Pictures/wallpapers

    # Download a sample dark wallpaper if directory is empty
    if [ -z "$(ls -A ~/Pictures/wallpapers 2>/dev/null)" ]; then
        echo "Downloading sample wallpaper..."
        curl -L -o ~/Pictures/wallpapers/gradient-dark.jpg \
            "https://images.unsplash.com/photo-1557683316-973673baf926?w=1920&q=80" 2>/dev/null || true
    fi

    echo -e "${GREEN}✓${NC} Wallpaper directory ready"
}

# Main installation
main() {
    install_packages
    install_paru
    install_aur_packages
    setup_fonts
    setup_wallpapers

    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                 Installation Complete!                      ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Next steps:"
    echo "  1. Log out and log back in (or reboot)"
    echo "  2. Add some wallpapers to ~/Pictures/wallpapers/"
    echo ""
    echo "Keybinds:"
    echo "  SUPER + SPACE      → App launcher (rofi)"
    echo "  SUPER + N          → Clock widget"
    echo "  SUPER + SHIFT + N  → Power menu"
    echo "  SUPER + M          → Media player"
    echo "  SUPER + W          → Wallpaper selector"
    echo ""
}

main "$@"
