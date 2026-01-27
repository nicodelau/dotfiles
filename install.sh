#!/bin/bash

# Install dotfiles using GNU Stow
# This script symlinks the configs from dotfiles to home directory

cd "$(dirname "$0")" || exit 1

echo "Installing dotfiles..."

# Create .config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Stow configuration directories
stow --dir "$(pwd)" --target "$HOME" hypr
stow --dir "$(pwd)" --target "$HOME" kitty
stow --dir "$(pwd)" --target "$HOME" nvim
stow --dir "$(pwd)" --target "$HOME" rofi
stow --dir "$(pwd)" --target "$HOME" dunst
stow --dir "$(pwd)" --target "$HOME" eww
stow --dir "$(pwd)" --target "$HOME" wezterm

# Stow files directly to .config
stow --dir "$(pwd)" --target "$HOME/.config" mimeapps.list

# Create symlink for wallpapers
if [ -d "$(pwd)/wallpapers" ]; then
    echo "Creating wallpaper symlink..."
    ln -sf "$(pwd)/wallpapers" "$HOME/Pictures/wallpapers"
fi

echo "Dotfiles installed. Reload your shell or restart apps if needed."

