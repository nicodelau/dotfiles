#!/bin/bash

set -e

echo "🔍 Verificando si Neovim está instalado..."
if ! command -v nvim &> /dev/null; then
    echo "📦 Neovim no encontrado. Instalando con pacman..."
    sudo pacman -Sy --noconfirm neovim
else
    echo "✅ Neovim ya está instalado."
fi

echo "📦 Instalando dependencias necesarias..."
sudo pacman -Sy --noconfirm git curl unzip ripgrep fd

echo "🧼 Haciendo backup de configuraciones anteriores..."
mkdir -p ~/.nvim_backups
timestamp=$(date +%Y%m%d%H%M%S)
mv ~/.config/nvim ~/.nvim_backups/nvim_$timestamp 2>/dev/null || true
mv ~/.local/share/nvim ~/.nvim_backups/share_$timestamp 2>/dev/null || true
mv ~/.local/state/nvim ~/.nvim_backups/state_$timestamp 2>/dev/null || true
mv ~/.cache/nvim ~/.nvim_backups/cache_$timestamp 2>/dev/null || true

echo "🌱 Clonando tu configuración de Neovim (LazyVim personalizada)..."
git clone git@github.com:nicodelau/nvim.git ~/.config/nvim

echo "⚙️ Configurando nvim como editor por defecto..."
shell_rc=""
if [[ "$SHELL" == *zsh ]]; then
    shell_rc="$HOME/.zshrc"
elif [[ "$SHELL" == *bash ]]; then
    shell_rc="$HOME/.bashrc"
fi

if [ -n "$shell_rc" ]; then
    grep -qxF 'export EDITOR=nvim' "$shell_rc" || echo 'export EDITOR=nvim' >> "$shell_rc"
    grep -qxF 'export VISUAL=nvim' "$shell_rc" || echo 'export VISUAL=nvim' >> "$shell_rc"
    echo "✅ Variables EDITOR y VISUAL agregadas a $shell_rc"
else
    echo "⚠️ No se pudo detectar el shell. Agregá manualmente 'export EDITOR=nvim' a tu archivo de configuración."
fi

echo "🚀 Iniciando Neovim para instalar plugins..."
nvim --headless "+Lazy! sync" +qa

echo ""
echo "🎉 ¡Listo Nico! Tu LazyVim ya está funcionando."
echo "👉 Ejecutá 'nvim' para empezar."

