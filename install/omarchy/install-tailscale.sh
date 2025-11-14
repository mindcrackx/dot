#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing Tailscale ==="
echo ""

# Install Tailscale CLI
echo "Step 1: Installing Tailscale from official repos..."
if pacman -Q tailscale &>/dev/null; then
    echo "  Tailscale is already installed, skipping..."
else
    yay -S --noconfirm --needed tailscale
fi
echo "✓ Tailscale installed"
echo ""

# Install tsui TUI
echo "Step 2: Installing tsui (Tailscale TUI) from AUR..."
if pacman -Q tsui &>/dev/null; then
    echo "  tsui is already installed, skipping..."
else
    yay -S --noconfirm --needed tsui
fi
echo "✓ tsui installed"
echo ""

# Enable and start tailscaled service
echo "Step 3: Enabling tailscaled service..."
if systemctl is-enabled tailscaled.service &>/dev/null; then
    echo "  tailscaled service is already enabled, skipping..."
else
    sudo systemctl enable --now tailscaled.service
    echo "  Enabled and started tailscaled service"
fi
echo "✓ Tailscaled service is running"
echo ""

echo "=== Tailscale Setup Complete ==="
echo ""
echo "Tailscale daemon is running but not connected."
echo ""
echo "To connect:"
echo "  - TUI: Super + Space → type 'tsui' → Run 'sudo tsui' → Navigate and connect"
echo "  - CLI: sudo tailscale up"
echo ""
echo "To disconnect:"
echo "  - TUI: Use tsui interface"
echo "  - CLI: sudo tailscale down"
echo ""
