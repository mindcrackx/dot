#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing VSCode ==="
echo ""

# Check if Omarchy's VSCode installer exists
OMARCHY_INSTALLER="/home/mpn/.local/share/omarchy/bin/omarchy-install-vscode"

if [ ! -f "$OMARCHY_INSTALLER" ]; then
    echo "Error: Omarchy VSCode installer not found at $OMARCHY_INSTALLER"
    echo "Is Omarchy installed?"
    exit 1
fi

# Check if VSCode is already installed
if pacman -Q visual-studio-code-bin &>/dev/null; then
    echo "✓ VSCode is already installed"
    echo ""

    # Still apply theme if needed
    if command -v omarchy-theme-set-vscode &>/dev/null; then
        echo "Applying Omarchy theme to VSCode..."
        omarchy-theme-set-vscode
    fi
else
    echo "Installing VSCode via Omarchy installer..."
    "$OMARCHY_INSTALLER"
fi

echo ""
echo "=== VSCode Setup Complete ==="
echo ""
echo "VSCode is installed with Omarchy theming."
echo "Launch with: Super + Shift + N → VSCode"
echo "Or: Super + Space → type 'code'"
echo ""
