#!/bin/bash

# System Dependencies Installation Script
# This script installs paru and all necessary dependencies for the dotfiles

set -e

echo "🚀 Starting system setup for dotfiles..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root!"
    exit 1
fi

# Update system
print_status "Updating system packages..."
sudo pacman -Syu --noconfirm

# Install base development tools
print_status "Installing base development tools..."
sudo pacman -S --noconfirm \
    base-devel \
    git \
    curl \
    wget \
    stow \
    neovim \
    python \
    python-pip \
    nodejs \
    npm \
    go \
    rust \
    cargo

# Install paru (AUR helper)
print_status "Installing paru (AUR helper)..."
if ! command -v paru &> /dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
    print_status "Paru installed successfully!"
else
    print_warning "Paru is already installed"
fi

# Install Hyprland and related packages
print_status "Installing Hyprland and window manager components..."
paru -S --noconfirm \
    hyprland \
    hyprpaper \
    hyprpicker \
    hyprcursor \
    xdg-desktop-portal-hyprland \
    qt5-wayland \
    qt6-wayland

# Install terminal and shell tools
print_status "Installing terminal and shell tools..."
paru -S --noconfirm \
    kitty \
    wezterm \
    zsh \
    oh-my-zsh-git \
    fastfetch \
    neofetch \
    tmux

# Install application launchers and bars
print_status "Installing launchers and status bars..."
paru -S --noconfirm \
    rofi \
    rofi-emoji \
    eww \
    waybar

# Install notification system
print_status "Installing notification system..."
paru -S --noconfirm \
    dunst \
    libnotify

# Install file manager and utilities
print_status "Installing file manager and utilities..."
paru -S --noconfirm \
    yazi \
    thunar \
    thunar-archive-plugin \
    file-roller

# Install screenshot and recording tools
print_status "Installing screenshot and recording tools..."
paru -S --noconfirm \
    grim \
    slurp \
    wf-recorder \
    swappy

# Install system monitoring
print_status "Installing system monitoring tools..."
paru -S --noconfirm \
    btop \
    htop \
    iotop

# Install network tools
print_status "Installing network tools..."
paru -S --noconfirm \
    networkmanager \
    network-manager-applet \
    blueman

# Install audio tools
print_status "Installing audio tools..."
paru -S --noconfirm \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    wireplumber \
    pavucontrol \
    pamixer

# Install fonts
print_status "Installing fonts..."
paru -S --noconfirm \
    ttf-jetbrains-mono \
    ttf-jetbrains-mono-nerd \
    noto-fonts \
    noto-fonts-emoji \
    fontawesome

# Install development tools
print_status "Installing additional development tools..."
paru -S --noconfirm \
    lazygit \
    fzf \
    fd \
    ripgrep \
    bat \
    eza

# Install theming and appearance
print_status "Installing theming tools..."
paru -S --noconfirm \
    lxappearance \
    qt5ct \
    qt6ct \
    adwaita-icon-theme \
    papirus-icon-theme

# Install clipboard manager
print_status "Installing clipboard manager..."
paru -S --noconfirm \
    wl-clipboard \
    cliphist

# Install auto-start manager
print_status "Installing auto-start manager..."
paru -S --noconfirm \
    dex

# Install additional utilities
print_status "Installing additional utilities..."
paru -S --noconfirm \
    brightnessctl \
    playerctl \
    xdg-utils

# Enable necessary services
print_status "Enabling system services..."
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable pipewire-pulse

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p "$HOME/.local/share"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/autostart"

# Set default shell to zsh if installed
if command -v zsh &> /dev/null; then
    print_status "Setting default shell to zsh..."
    sudo chsh -s "$(which zsh)" "$USER"
fi

# Clean up
print_status "Cleaning up package cache..."
paru -Scc --noconfirm

print_status "✅ System setup completed!"
print_status "🎯 Next steps:"
print_status "1. Run ./install.sh to symlink dotfiles"
print_status "2. Reboot or restart your session"
print_status "3. Enjoy your new setup!"

echo ""
print_warning "Note: Some applications may require manual configuration or additional setup."
print_warning "Please check the individual config files in the dotfiles repository."