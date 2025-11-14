#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Paths
HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
OVERRIDES_FILE="$SCRIPT_DIR/omarchy-overrides.conf"
SOURCE_LINE="source = $OVERRIDES_FILE"

echo "=== Omarchy Overrides Setup ==="
echo ""

# Check if hyprland.conf exists
if [ ! -f "$HYPRLAND_CONF" ]; then
    echo "Error: Hyprland config not found at $HYPRLAND_CONF"
    echo "Please ensure Omarchy/Hyprland is installed first."
    exit 1
fi

# Check if overrides file exists
if [ ! -f "$OVERRIDES_FILE" ]; then
    echo "Error: Overrides file not found at $OVERRIDES_FILE"
    exit 1
fi

echo "✓ Found Hyprland config: $HYPRLAND_CONF"
echo "✓ Found overrides file: $OVERRIDES_FILE"
echo ""

# Check if source line already exists
if grep -Fxq "$SOURCE_LINE" "$HYPRLAND_CONF"; then
    echo "✓ Overrides already sourced in hyprland.conf"
    echo "  No changes needed."
else
    echo "Adding source line to hyprland.conf..."
    echo "" >> "$HYPRLAND_CONF"
    echo "# Personal overrides from dotfiles" >> "$HYPRLAND_CONF"
    echo "$SOURCE_LINE" >> "$HYPRLAND_CONF"
    echo "✓ Source line added to hyprland.conf"
    echo ""
fi

echo ""
echo "=== Setup Complete ==="
