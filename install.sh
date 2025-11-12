#!/bin/bash

# Install dotfiles using GNU Stow
# This script symlinks the configs from dotfiles to home directory

cd "$(dirname "$0")" || exit 1

echo "Installing dotfiles..."

stow --dir "$(pwd)" --target "$HOME" hypr ; stow --dir "$(pwd)" --target "$HOME" ghostty ; stow --dir "$(pwd)" --target "$HOME" yazi ; stow --dir "$(pwd)" --target "$HOME" zsh ; stow --dir "$(pwd)" --target "$HOME" tmux

echo "Dotfiles installed. Reload your shell or restart apps if needed."