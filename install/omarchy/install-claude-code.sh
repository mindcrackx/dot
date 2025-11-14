#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Installing Claude Code ==="
echo ""

# Install Claude Code from AUR
echo "Step 1: Installing Claude Code from AUR..."
if pacman -Q claude-code &>/dev/null; then
    echo "  Claude Code is already installed, skipping..."
else
    yay -S --noconfirm --needed claude-code
fi
echo "✓ Claude Code installed"
echo ""

# Create .claude directory if it doesn't exist
echo "Step 2: Setting up Claude Code configuration..."
mkdir -p ~/.claude

# Symlink settings file (optional, for future project settings)
SETTINGS_SOURCE="$SCRIPT_DIR/settings.json"
SETTINGS_TARGET="$HOME/.claude/settings.json"

if [ -L "$SETTINGS_TARGET" ]; then
    echo "  Removing existing symlink at $SETTINGS_TARGET"
    rm "$SETTINGS_TARGET"
elif [ -f "$SETTINGS_TARGET" ]; then
    echo "  Backing up existing settings to $SETTINGS_TARGET.backup"
    mv "$SETTINGS_TARGET" "$SETTINGS_TARGET.backup"
fi

ln -s "$SETTINGS_SOURCE" "$SETTINGS_TARGET"
echo "✓ Settings file symlinked to ~/.claude/settings.json"
echo ""

echo "=== Claude Code Setup Complete ==="
echo ""
echo "To enable Vim mode (user preference):"
echo "  1. Run: claude"
echo "  2. Type: /config"
echo "  3. Select 'Editor mode' and choose 'Vim'"
echo ""
echo "Or use /vim in any session for temporary vim mode."
echo ""
