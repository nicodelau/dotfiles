#!/usr/bin/env bash
# ==============================================================================
# Setup Script - Arch Linux Antigravity CLI (agy) & Claude Code Environment
# Location: ~/Documents/GitHub/dotfiles/scripts/setup-ai.sh
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Formatting Helpers
# ------------------------------------------------------------------------------
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ------------------------------------------------------------------------------
# 1. System Dependencies Installation (Arch Linux)
# ------------------------------------------------------------------------------
info "Detecting package manager..."
if ! command -v pacman &> /dev/null; then
    error "Pacman not found. This script requires an Arch Linux system."
fi

# Core Packages to Install via pacman
PACKAGES=(
    git
    nodejs
    npm
    tree-sitter
    tree-sitter-cli
    ripgrep
    fd
)

info "Installing system dependencies via pacman..."
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

# ------------------------------------------------------------------------------
# 2. Install Claude Code (Uses your Enterprise web account)
# ------------------------------------------------------------------------------
info "Installing/Checking Claude Code CLI..."
if ! command -v claude &> /dev/null; then
    info "Downloading and running the official Claude Code installer..."
    curl -fsSL https://claude.ai/install.sh | bash
    success "Claude Code installed successfully!"
else
    info "Claude Code is already installed."
fi

# ------------------------------------------------------------------------------
# 3. Verify Antigravity CLI Installation
# ------------------------------------------------------------------------------
info "Checking for Antigravity CLI (agy)..."
if ! command -v agy &> /dev/null; then
    error "Antigravity CLI (agy) is not installed or not in your PATH. Please install it first."
else
    success "Antigravity CLI (agy) detected."
fi

# ------------------------------------------------------------------------------
# 4. Create Directories and Symlinks
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_AGY_DIR="$HOME/.gemini/antigravity-cli"
CONFIG_GEMINI_DIR="$HOME/.gemini/config"
CONFIG_CLAUDE_DIR="$HOME/.claude"


info "Creating configuration directories..."
mkdir -p "$CONFIG_AGY_DIR"
mkdir -p "$CONFIG_GEMINI_DIR"
mkdir -p "$CONFIG_CLAUDE_DIR"

info "Creating symbolic links for configurations..."

# Backup existing configurations if they are regular files and not symlinks
backup_if_needed() {
    local target="$1"
    if [ -f "$target" ] && [ ! -L "$target" ]; then
        warn "Backing up existing file $target to ${target}.bak"
        mv "$target" "${target}.bak"
    fi
}

# 1. Antigravity settings.json
if [ -f "$DOTFILES_DIR/ai/settings.json" ]; then
    backup_if_needed "$CONFIG_AGY_DIR/settings.json"
    ln -sf "$DOTFILES_DIR/ai/settings.json" "$CONFIG_AGY_DIR/settings.json"
    success "Symlinked settings.json"
else
    error "settings.json not found in $DOTFILES_DIR/ai/"
fi

# 2. Claude Code settings.json
if [ -f "$DOTFILES_DIR/ai/claude_settings.json" ]; then
    backup_if_needed "$CONFIG_CLAUDE_DIR/settings.json"
    ln -sf "$DOTFILES_DIR/ai/claude_settings.json" "$CONFIG_CLAUDE_DIR/settings.json"
    success "Symlinked Claude Code settings.json to $CONFIG_CLAUDE_DIR/settings.json"
else
    error "claude_settings.json not found in $DOTFILES_DIR/ai/"
fi

# 3. Antigravity and Claude Code MCP configs
if [ -f "$DOTFILES_DIR/ai/mcp_config.json" ]; then
    # Antigravity MCP Config
    backup_if_needed "$CONFIG_GEMINI_DIR/mcp_config.json"
    ln -sf "$DOTFILES_DIR/ai/mcp_config.json" "$CONFIG_GEMINI_DIR/mcp_config.json"
    
    # Claude Code MCP Config
    backup_if_needed "$HOME/.claude.json"
    ln -sf "$DOTFILES_DIR/ai/mcp_config.json" "$HOME/.claude.json"
    success "Symlinked MCP configs to both agy (~/.gemini/config/) and claude (~/.claude.json)"
else
    error "mcp_config.json not found in $DOTFILES_DIR/ai/"
fi

# 4. Antigravity Global Rules (GEMINI.md)
if [ -f "$DOTFILES_DIR/ai/GEMINI.md" ]; then
    backup_if_needed "$CONFIG_GEMINI_DIR/GEMINI.md"
    ln -sf "$DOTFILES_DIR/ai/GEMINI.md" "$CONFIG_GEMINI_DIR/GEMINI.md"
    success "Symlinked GEMINI.md"
else
    error "GEMINI.md not found in $DOTFILES_DIR/ai/"
fi

# 5. Claude Code Global Rules (CLAUDE.md)
if [ -f "$DOTFILES_DIR/ai/prompts/CLAUDE.md" ]; then
    backup_if_needed "$CONFIG_CLAUDE_DIR/CLAUDE.md"
    ln -sf "$DOTFILES_DIR/ai/prompts/CLAUDE.md" "$CONFIG_CLAUDE_DIR/CLAUDE.md"
    success "Symlinked CLAUDE.md to $CONFIG_CLAUDE_DIR/CLAUDE.md"
else
    error "CLAUDE.md not found in $DOTFILES_DIR/ai/prompts/"
fi

# 6. Global Ignore File (.geminiignore)
if [ -f "$DOTFILES_DIR/ai/.geminiignore" ]; then
    backup_if_needed "$HOME/.geminiignore"
    ln -sf "$DOTFILES_DIR/ai/.geminiignore" "$HOME/.geminiignore"
    ln -sf "$DOTFILES_DIR/ai/.geminiignore" "$HOME/.aiexclude"
    success "Symlinked ignore files (~/.geminiignore & ~/.aiexclude)"
else
    error ".geminiignore not found in $DOTFILES_DIR/ai/"
fi

# ------------------------------------------------------------------------------
# 5. Zsh Shell Integration
# ------------------------------------------------------------------------------
ZSHRC="$HOME/.zshrc"
ALIASES_SOURCE="source $DOTFILES_DIR/zsh/ai_aliases.zsh"

if [ -f "$ZSHRC" ]; then
    if grep -Fq "ai_aliases.zsh" "$ZSHRC"; then
        info "Aliases already sourced in ~/.zshrc"
    else
        info "Adding aliases sourcing to ~/.zshrc..."
        echo -e "\n# Antigravity CLI & Claude Code Aliases\nif [ -f \"$DOTFILES_DIR/zsh/ai_aliases.zsh\" ]; then\n    $ALIASES_SOURCE\nfi" >> "$ZSHRC"
        success "Added Zsh aliases source to ~/.zshrc"
    fi
else
    warn "~/.zshrc not found. Please manually add '$ALIASES_SOURCE' to your shell RC file."
fi

success "Agentic Environment configuration complete!"
info "Please run: 'source ~/.zshrc' to load the new aliases."
info "Run the router using: 'ai' (or specify manually with 'af' or 'ad' / 'c')"
