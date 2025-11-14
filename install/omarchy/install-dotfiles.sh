#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT_DIR="$SCRIPT_DIR/../.."

echo "=== Installing Dotfiles ==="
echo ""

# Symlink scripts folder
echo "Step 1: Linking Scripts folder..."
SCRIPTS_SOURCE="$DOT_DIR/scripts"
SCRIPTS_TARGET="$HOME/Scripts"

if [ ! -d "$SCRIPTS_SOURCE" ]; then
    echo "Error: Scripts folder not found at $SCRIPTS_SOURCE"
    exit 1
fi

if [ -L "$SCRIPTS_TARGET" ] && [ "$(readlink -f "$SCRIPTS_TARGET")" = "$(readlink -f "$SCRIPTS_SOURCE")" ]; then
    echo "  Scripts folder already linked, skipping..."
else
    if [ -e "$SCRIPTS_TARGET" ]; then
        echo "  Backing up existing Scripts to $SCRIPTS_TARGET.backup"
        mv "$SCRIPTS_TARGET" "$SCRIPTS_TARGET.backup"
    fi
    ln -s "$SCRIPTS_SOURCE" "$SCRIPTS_TARGET"
    echo "  Linked Scripts folder"
fi
echo "✓ Scripts folder installed"
echo ""

# Symlink .inputrc
echo "Step 2: Linking .inputrc..."
INPUTRC_SOURCE="$DOT_DIR/.inputrc"
INPUTRC_TARGET="$HOME/.inputrc"

if [ ! -f "$INPUTRC_SOURCE" ]; then
    echo "Error: .inputrc not found at $INPUTRC_SOURCE"
    exit 1
fi

if [ -L "$INPUTRC_TARGET" ] && [ "$(readlink -f "$INPUTRC_TARGET")" = "$(readlink -f "$INPUTRC_SOURCE")" ]; then
    echo "  .inputrc already linked, skipping..."
else
    if [ -e "$INPUTRC_TARGET" ]; then
        echo "  Backing up existing .inputrc to $INPUTRC_TARGET.backup"
        mv "$INPUTRC_TARGET" "$INPUTRC_TARGET.backup"
    fi
    ln -s "$INPUTRC_SOURCE" "$INPUTRC_TARGET"
    echo "  Linked .inputrc"
fi
echo "✓ .inputrc installed"
echo ""

# Symlink .bashrc
echo "Step 3: Linking .bashrc..."
BASHRC_SOURCE="$SCRIPT_DIR/.bashrc"
BASHRC_TARGET="$HOME/.bashrc"

if [ ! -f "$BASHRC_SOURCE" ]; then
    echo "Error: .bashrc not found at $BASHRC_SOURCE"
    exit 1
fi

if [ -L "$BASHRC_TARGET" ] && [ "$(readlink -f "$BASHRC_TARGET")" = "$(readlink -f "$BASHRC_SOURCE")" ]; then
    echo "  .bashrc already linked, skipping..."
else
    if [ -e "$BASHRC_TARGET" ]; then
        echo "  Backing up existing .bashrc to $BASHRC_TARGET.backup"
        mv "$BASHRC_TARGET" "$BASHRC_TARGET.backup"
    fi
    ln -s "$BASHRC_SOURCE" "$BASHRC_TARGET"
    echo "  Linked .bashrc"
fi
echo "✓ .bashrc installed"
echo ""

# Setup .gitconfig
echo "Step 4: Setting up .gitconfig..."
GITCONFIG_TEMPLATE="$DOT_DIR/.gitconfig_template"
PRIVATE_DIR="$HOME/Private"
PRIVATE_GITCONFIG="$PRIVATE_DIR/.gitconfig"
GITCONFIG_TARGET="$HOME/.gitconfig"
XDG_GITCONFIG="$HOME/.config/git/config"

# Ensure Private directory exists
if [ ! -d "$PRIVATE_DIR" ]; then
    echo "  Creating ~/Private directory..."
    mkdir -p "$PRIVATE_DIR"
fi

# Ensure Private/.gitconfig exists
if [ ! -f "$PRIVATE_GITCONFIG" ]; then
    echo "  ~/Private/.gitconfig not found, copying from template..."
    cp "$GITCONFIG_TEMPLATE" "$PRIVATE_GITCONFIG"
    echo "  ⚠️  Please edit ~/Private/.gitconfig to set your email, name, and GPG key"
fi

# Check if .gitconfig already correctly linked
if [ -L "$GITCONFIG_TARGET" ] && [ "$(readlink -f "$GITCONFIG_TARGET")" = "$(readlink -f "$PRIVATE_GITCONFIG")" ]; then
    echo "  ~/.gitconfig already linked to ~/Private/.gitconfig, skipping..."
# Check if .gitconfig exists (file or symlink to somewhere else)
elif [ -e "$GITCONFIG_TARGET" ] || [ -L "$GITCONFIG_TARGET" ]; then
    if [ -L "$GITCONFIG_TARGET" ]; then
        echo "  Found existing .gitconfig symlink pointing to: $(readlink "$GITCONFIG_TARGET")"
    else
        echo "  Found existing .gitconfig file"
    fi
    read -rp "  Replace with symlink to ~/Private/.gitconfig? (y/N): " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "  Backing up existing .gitconfig to $GITCONFIG_TARGET.backup"
        mv "$GITCONFIG_TARGET" "$GITCONFIG_TARGET.backup"
        ln -s "$PRIVATE_GITCONFIG" "$GITCONFIG_TARGET"
        echo "  Linked ~/.gitconfig → ~/Private/.gitconfig"
    else
        echo "  Keeping existing git config"
    fi
# Check for XDG config location
elif [ -f "$XDG_GITCONFIG" ]; then
    echo "  Found existing git config at: $XDG_GITCONFIG"
    read -rp "  Replace with symlink to ~/Private/.gitconfig? (y/N): " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "  Backing up existing XDG git config to $XDG_GITCONFIG.backup"
        mv "$XDG_GITCONFIG" "$XDG_GITCONFIG.backup"
        ln -s "$PRIVATE_GITCONFIG" "$GITCONFIG_TARGET"
        echo "  Linked ~/.gitconfig → ~/Private/.gitconfig"
    else
        echo "  Keeping existing git config"
    fi
# No existing config, create symlink
else
    ln -s "$PRIVATE_GITCONFIG" "$GITCONFIG_TARGET"
    echo "  Linked ~/.gitconfig → ~/Private/.gitconfig"
fi

echo "✓ .gitconfig setup complete"
echo ""

echo "=== Dotfiles Setup Complete ==="
echo ""
echo "Installed:"
echo "  ✓ ~/Scripts → utility scripts (g, k, d, ll, vi, and more)"
echo "  ✓ ~/.bashrc → shell configuration"
echo "  ✓ ~/.inputrc → readline/vim mode configuration"
echo "  ✓ ~/.gitconfig → git configuration (linked to ~/Private/.gitconfig)"
echo ""

# Build next steps list
NEXT_STEPS=()
if [ ! -f "$PRIVATE_GITCONFIG" ] || grep -q "youremail@example.com" "$PRIVATE_GITCONFIG" 2>/dev/null; then
    NEXT_STEPS+=("Edit ~/Private/.gitconfig to set your email, name, and GPG key")
fi
NEXT_STEPS+=("Restart your shell: source ~/.bashrc")

if [ ${#NEXT_STEPS[@]} -gt 0 ]; then
    echo "Next steps:"
    for i in "${!NEXT_STEPS[@]}"; do
        echo "  $((i+1)). ${NEXT_STEPS[$i]}"
    done
    echo ""
fi
