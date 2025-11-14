#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Installing tmux ==="
echo ""

# Install tmux
echo "Step 1: Installing tmux from official repos..."
if pacman -Q tmux &>/dev/null; then
    echo "  tmux is already installed, skipping..."
else
    yay -S --noconfirm --needed tmux
fi
echo "✓ tmux installed"
echo ""

# Symlink tmux config
echo "Step 2: Setting up tmux configuration..."
TMUX_SOURCE="$SCRIPT_DIR/../../tmux/.tmux.conf"
TMUX_TARGET="$HOME/.tmux.conf"

# Check if source exists
if [ ! -f "$TMUX_SOURCE" ]; then
    echo "Error: tmux config not found at $TMUX_SOURCE"
    exit 1
fi

# Check if symlink already exists and points to our source
if [ -L "$TMUX_TARGET" ] && [ "$(readlink -f "$TMUX_TARGET")" = "$(readlink -f "$TMUX_SOURCE")" ]; then
    echo "  tmux config already linked, skipping..."
else
    # Backup existing config if it exists
    if [ -e "$TMUX_TARGET" ]; then
        echo "  Backing up existing config to $TMUX_TARGET.backup"
        mv "$TMUX_TARGET" "$TMUX_TARGET.backup"
    fi

    # Create symlink
    ln -s "$TMUX_SOURCE" "$TMUX_TARGET"
    echo "  Linked tmux config"
fi
echo "✓ tmux configured"
echo ""

echo "=== tmux Setup Complete ==="
echo ""
echo "tmux is installed with your dotfile configuration."
echo "Start tmux with: tmux"
echo "Prefix key: Ctrl+A"
echo ""
