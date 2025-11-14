#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Installing KeePassXC ==="
echo ""

# Install KeePassXC
echo "Step 1: Installing KeePassXC from official repos..."
if pacman -Q keepassxc &>/dev/null; then
    echo "  KeePassXC is already installed, skipping..."
else
    yay -S --noconfirm --needed keepassxc
fi
echo "✓ KeePassXC installed"
echo ""

# Setup KeePassXC configuration
echo "Step 2: Setting up KeePassXC configuration..."
KEEPASSXC_CONFIG_DIR="$HOME/.config/keepassxc"
KEEPASSXC_CONFIG_SOURCE="$SCRIPT_DIR/keepassxc.ini"
KEEPASSXC_CONFIG_TARGET="$KEEPASSXC_CONFIG_DIR/keepassxc.ini"

# Create config directory if it doesn't exist
if [ ! -d "$KEEPASSXC_CONFIG_DIR" ]; then
    echo "  Creating KeePassXC config directory..."
    mkdir -p "$KEEPASSXC_CONFIG_DIR"
fi

# Check if config already linked
if [ -L "$KEEPASSXC_CONFIG_TARGET" ] && [ "$(readlink -f "$KEEPASSXC_CONFIG_TARGET")" = "$(readlink -f "$KEEPASSXC_CONFIG_SOURCE")" ]; then
    echo "  KeePassXC config already linked, skipping..."
# Check if config exists (file or symlink to somewhere else)
elif [ -e "$KEEPASSXC_CONFIG_TARGET" ] || [ -L "$KEEPASSXC_CONFIG_TARGET" ]; then
    if [ -L "$KEEPASSXC_CONFIG_TARGET" ]; then
        echo "  Found existing config symlink pointing to: $(readlink "$KEEPASSXC_CONFIG_TARGET")"
    else
        echo "  Found existing keepassxc.ini file"
    fi
    read -rp "  Replace with symlink to dotfiles config? (y/N): " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "  Backing up existing config to $KEEPASSXC_CONFIG_TARGET.backup"
        mv "$KEEPASSXC_CONFIG_TARGET" "$KEEPASSXC_CONFIG_TARGET.backup"
        ln -s "$KEEPASSXC_CONFIG_SOURCE" "$KEEPASSXC_CONFIG_TARGET"
        echo "  Linked KeePassXC config"
    else
        echo "  Keeping existing config"
    fi
# No existing config, create symlink
else
    ln -s "$KEEPASSXC_CONFIG_SOURCE" "$KEEPASSXC_CONFIG_TARGET"
    echo "  Linked KeePassXC config"
fi
echo "✓ KeePassXC configuration complete"
echo ""

echo "=== KeePassXC Setup Complete ==="
echo ""
echo "KeePassXC is now installed and configured."
echo ""
echo "Features enabled:"
echo "  ✓ Browser integration (Firefox extension auto-installs)"
echo "  ✓ Auto-lock after 5 minutes of inactivity"
echo "  ✓ Auto-lock on screen lock"
echo "  ✓ Clipboard clears after 10 seconds"
echo "  ✓ Window blocked from screen sharing (Hyprland security)"
echo ""
echo "Keybinding:"
echo "  - Super + Shift + K to launch KeePassXC"
echo ""
echo "Next steps:"
echo "  1. Open KeePassXC and create/open your database"
echo "  2. Enable browsers: Settings → Browser Integration → Check Firefox/Chrome/Chromium"
echo "  3. In Firefox, click KeePassXC-Browser icon → Connect"
echo ""
echo "Note: You must manually check browser checkboxes in KeePassXC GUI to enable them."
echo ""
