#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Omarchy Uninstall Script ==="
echo ""
echo "This script will remove Omarchy dotfiles and optionally uninstall packages."
echo ""

# Function to confirm actions
confirm() {
  local prompt="$1"
  local response
  read -rp "$prompt (y/N): " response
  [[ "$response" =~ ^[Yy]$ ]]
}

# 1. Remove dotfile symlinks
echo "=== Removing Dotfile Symlinks ==="
echo ""

# Remove Scripts symlink
if [ -L "$HOME/Scripts" ]; then
  echo "Removing ~/Scripts symlink..."
  rm "$HOME/Scripts"
  echo "  Removed ~/Scripts"

  # Restore backup if exists
  if [ -e "$HOME/Scripts.backup" ]; then
    if confirm "Restore ~/Scripts from backup?"; then
      mv "$HOME/Scripts.backup" "$HOME/Scripts"
      echo "  Restored ~/Scripts from backup"
    fi
  fi
else
  echo "~/Scripts is not a symlink, skipping..."
fi
echo ""

# Remove .bashrc symlink
if [ -L "$HOME/.bashrc" ]; then
  echo "Removing ~/.bashrc symlink..."
  rm "$HOME/.bashrc"
  echo "  Removed ~/.bashrc"

  # Restore backup if exists
  if [ -e "$HOME/.bashrc.backup" ]; then
    if confirm "Restore ~/.bashrc from backup?"; then
      mv "$HOME/.bashrc.backup" "$HOME/.bashrc"
      echo "  Restored ~/.bashrc from backup"
    fi
  fi
else
  echo "~/.bashrc is not a symlink, skipping..."
fi
echo ""

# Remove .inputrc symlink
if [ -L "$HOME/.inputrc" ]; then
  echo "Removing ~/.inputrc symlink..."
  rm "$HOME/.inputrc"
  echo "  Removed ~/.inputrc"

  # Restore backup if exists
  if [ -e "$HOME/.inputrc.backup" ]; then
    if confirm "Restore ~/.inputrc from backup?"; then
      mv "$HOME/.inputrc.backup" "$HOME/.inputrc"
      echo "  Restored ~/.inputrc from backup"
    fi
  fi
else
  echo "~/.inputrc is not a symlink, skipping..."
fi
echo ""

# Remove .gitconfig symlink
if [ -L "$HOME/.gitconfig" ]; then
  GITCONFIG_TARGET=$(readlink "$HOME/.gitconfig")
  if [[ "$GITCONFIG_TARGET" == *"Private/.gitconfig"* ]]; then
    echo "Removing ~/.gitconfig symlink to Private folder..."
    rm "$HOME/.gitconfig"
    echo "  Removed ~/.gitconfig"

    # Restore backup if exists
    if [ -e "$HOME/.gitconfig.backup" ]; then
      if confirm "Restore ~/.gitconfig from backup?"; then
        mv "$HOME/.gitconfig.backup" "$HOME/.gitconfig"
        echo "  Restored ~/.gitconfig from backup"
      fi
    fi
  else
    echo "~/.gitconfig is symlinked but not to Private folder, skipping..."
  fi
else
  echo "~/.gitconfig is not a symlink, skipping..."
fi
echo ""

# Remove .gnupg symlink
if [ -L "$HOME/.gnupg" ]; then
  GNUPG_TARGET=$(readlink "$HOME/.gnupg")
  if [[ "$GNUPG_TARGET" == *"Private/gnupg"* ]]; then
    echo "Removing ~/.gnupg symlink to Private folder..."
    rm "$HOME/.gnupg"
    echo "  Removed ~/.gnupg"
    echo "  ⚠️  Your GPG keys are still in ~/Private/gnupg"
  else
    echo "~/.gnupg is symlinked but not to Private folder, skipping..."
  fi
else
  echo "~/.gnupg is not a symlink, skipping..."
fi
echo ""

# Remove KeePassXC config symlink
KEEPASSXC_CONFIG="$HOME/.config/keepassxc/keepassxc.ini"
if [ -L "$KEEPASSXC_CONFIG" ]; then
  KEEPASSXC_TARGET=$(readlink "$KEEPASSXC_CONFIG")
  if [[ "$KEEPASSXC_TARGET" == *"dot/install/omarchy/keepassxc.ini"* ]]; then
    echo "Removing KeePassXC config symlink..."
    rm "$KEEPASSXC_CONFIG"
    echo "  Removed KeePassXC config symlink"

    # Restore backup if exists
    if [ -e "$KEEPASSXC_CONFIG.backup" ]; then
      if confirm "Restore KeePassXC config from backup?"; then
        mv "$KEEPASSXC_CONFIG.backup" "$KEEPASSXC_CONFIG"
        echo "  Restored KeePassXC config from backup"
      fi
    fi
  else
    echo "KeePassXC config is symlinked but not to dotfiles, skipping..."
  fi
else
  echo "KeePassXC config is not a symlink, skipping..."
fi
echo ""

# 2. Remove Hyprland overrides
echo "=== Removing Hyprland Overrides ==="
echo ""

HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
OVERRIDES_FILE="$SCRIPT_DIR/omarchy-overrides.conf"
SOURCE_LINE="source = $OVERRIDES_FILE"

if [ -f "$HYPRLAND_CONF" ]; then
  if grep -Fq "$SOURCE_LINE" "$HYPRLAND_CONF"; then
    echo "Removing override source from hyprland.conf..."
    # Create backup
    cp "$HYPRLAND_CONF" "$HYPRLAND_CONF.backup"
    # Remove the source line and the comment before it
    sed -i "/# Personal overrides from dotfiles/d" "$HYPRLAND_CONF"
    sed -i "\|$SOURCE_LINE|d" "$HYPRLAND_CONF"
    echo "  Removed source line from hyprland.conf"
    echo "  Backup saved to $HYPRLAND_CONF.backup"
  else
    echo "Override source line not found in hyprland.conf, skipping..."
  fi
else
  echo "Hyprland config not found, skipping..."
fi
echo ""

# 3. Optionally uninstall packages
echo "=== Package Removal (Optional) ==="
echo ""
echo "The following packages were installed by the setup scripts:"
echo "  - claude-code"
echo "  - firefox"
echo "  - ghostty"
echo "  - keepassxc"
echo "  - tailscale, tsui"
echo "  - visual-studio-code-bin"
echo "  - tmux"
echo ""

if confirm "Do you want to uninstall these packages?"; then
  echo ""
  echo "Uninstalling packages..."

  # Stop tailscaled service if running
  if systemctl is-active tailscaled.service &>/dev/null; then
    echo "  Stopping tailscaled service..."
    sudo systemctl stop tailscaled.service
    sudo systemctl disable tailscaled.service
  fi

  # Uninstall packages
  yay -Rns --noconfirm claude-code firefox ghostty keepassxc tailscale tsui visual-studio-code-bin tmux 2>/dev/null || echo "  Some packages may not have been installed or already removed"

  echo "✓ Packages uninstalled"
else
  echo "  Skipping package removal"
fi
echo ""

# 4. Clean up package caches (optional)
if confirm "Do you want to clean package caches?"; then
  echo ""
  echo "Cleaning package caches..."
  yay -Sc --noconfirm
  echo "✓ Package caches cleaned"
fi
echo ""

echo "=== Uninstall Complete ==="
echo ""
echo "Your Omarchy setup has been removed."
echo ""
echo "Note: Personal config files were preserved:"
echo "  - ~/.bash_personal"
echo "  - ~/.bash_private"
echo "  - ~/.bash_work"
echo "  - ~/Private/.gitconfig (your git configuration)"
echo "  - ~/Private/gnupg (your GPG keys)"
echo ""
echo "Backup files (if any) are still in your home directory:"
echo "  - ~/Scripts.backup"
echo "  - ~/.bashrc.backup"
echo "  - ~/.inputrc.backup"
echo "  - ~/.gitconfig.backup"
echo "  - ~/.config/hypr/hyprland.conf.backup"
echo ""
