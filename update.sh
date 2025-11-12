#!/bin/bash

# Update dotfiles by copying current configs from system to repo
# Run this after making changes to configs

cd "$(dirname "$0")" || exit 1

echo "Updating dotfiles from system..."

# Hyprland
cp -r ~/.config/hypr/* hypr/.config/ 2>/dev/null || true

# Ghostty
cp -r ~/.config/ghostty/* ghostty/.config/ 2>/dev/null || true

# Yazi
cp -r ~/.config/yazi/* yazi/.config/ 2>/dev/null || true

# Zsh
cp ~/.zshrc zsh/ 2>/dev/null || true

# Tmux
cp ~/.tmux.conf tmux/ 2>/dev/null || true

echo "Dotfiles updated. Remember to commit changes."