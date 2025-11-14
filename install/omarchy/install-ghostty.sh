#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Installing Ghostty ==="
echo ""

# Install Ghostty
echo "Step 1: Installing Ghostty from AUR..."
if pacman -Q ghostty &>/dev/null; then
    echo "  Ghostty is already installed, skipping..."
else
    yay -S --noconfirm --needed ghostty
fi
echo "✓ Ghostty installed"
echo ""

# Set Ghostty as default terminal
echo "Step 2: Setting Ghostty as default terminal..."
TERMINALS_SOURCE="$SCRIPT_DIR/xdg-terminals.list"
TERMINALS_TARGET="$HOME/.config/xdg-terminals.list"

# Check if symlink already exists and points to our source
if [ -L "$TERMINALS_TARGET" ] && [ "$(readlink -f "$TERMINALS_TARGET")" = "$(readlink -f "$TERMINALS_SOURCE")" ]; then
    echo "  Terminal config already linked, skipping..."
else
    # Remove old file if it exists
    if [ -e "$TERMINALS_TARGET" ]; then
        echo "  Backing up existing config to $TERMINALS_TARGET.backup"
        mv "$TERMINALS_TARGET" "$TERMINALS_TARGET.backup"
    fi

    # Create symlink
    ln -s "$TERMINALS_SOURCE" "$TERMINALS_TARGET"
    echo "  Linked xdg-terminals.list"
fi
echo "✓ Ghostty set as default terminal"
echo ""

echo "=== Ghostty Setup Complete ==="
echo ""
echo "Ghostty is now your default terminal."
echo "Super + Return will launch Ghostty."
echo ""
