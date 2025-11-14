#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Installing Firefox ==="
echo ""

# Install Firefox
echo "Step 1: Installing Firefox from official repos..."
if pacman -Q firefox &>/dev/null; then
    echo "  Firefox is already installed, skipping..."
else
    yay -S --noconfirm --needed firefox
fi
echo "✓ Firefox installed"
echo ""

# Set Firefox as default browser
echo "Step 2: Setting Firefox as default browser..."
xdg-settings set default-web-browser firefox.desktop
echo "✓ Firefox set as default browser"
echo ""

# Install Firefox extensions via policies
echo "Step 3: Setting up Firefox extension policies..."
POLICIES_DIR="/etc/firefox/policies"
POLICIES_TARGET="$POLICIES_DIR/policies.json"
POLICIES_SOURCE="$SCRIPT_DIR/policies.json"

# Check if symlink already exists and points to our source
if [ -L "$POLICIES_TARGET" ] && [ "$(readlink -f "$POLICIES_TARGET")" = "$(readlink -f "$POLICIES_SOURCE")" ]; then
    echo "  Policies already linked, skipping..."
else
    # Create policies directory if it doesn't exist (requires sudo)
    if [ ! -d "$POLICIES_DIR" ]; then
        echo "  Creating policies directory (requires sudo)..."
        sudo mkdir -p "$POLICIES_DIR"
    fi

    # Remove old policies file if it exists
    if [ -e "$POLICIES_TARGET" ]; then
        echo "  Removing old policies file (requires sudo)..."
        sudo rm "$POLICIES_TARGET"
    fi

    # Create symlink (requires sudo)
    echo "  Linking policies.json (requires sudo)..."
    sudo ln -s "$POLICIES_SOURCE" "$POLICIES_TARGET"
fi
echo "✓ Firefox extensions will auto-install on first launch"
echo ""

echo "=== Firefox Setup Complete ==="
echo ""
echo "Firefox is now your default browser with extensions:"
echo "  - uBlock Origin, Dark Reader, Privacy Badger"
echo "  - Return YouTube Dislike, Enhancer for YouTube"
echo "  - Video DownloadHelper, Keepa, KeePassXC-Browser"
echo ""
echo "Super + Shift + B will launch Firefox."
echo "Extensions will install automatically on first Firefox launch."
echo ""
