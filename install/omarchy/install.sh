#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Omarchy Setup Script ==="
echo ""
echo "This script will set up your Omarchy environment."
echo ""

# Run Claude Code installation
"$SCRIPT_DIR/install-claude-code.sh"

# Run Firefox installation
"$SCRIPT_DIR/install-firefox.sh"

# Run Ghostty installation
"$SCRIPT_DIR/install-ghostty.sh"

# Run KeePassXC installation
"$SCRIPT_DIR/install-keepassxc.sh"

# Run Tailscale installation
"$SCRIPT_DIR/install-tailscale.sh"

# Run VSCode installation
"$SCRIPT_DIR/install-vscode.sh"

# Run tmux installation
"$SCRIPT_DIR/install-tmux.sh"

# Run dotfiles installation (scripts, .inputrc)
"$SCRIPT_DIR/install-dotfiles.sh"

# Run Omarchy overrides installation
"$SCRIPT_DIR/install-overrides.sh"

echo ""
echo "=== All Setup Complete ==="
echo ""
echo "Your Omarchy environment is ready!"
echo ""
echo "Next steps:"
echo "  - Enable vim mode in Claude Code: /config"
echo "  - Firefox extensions will auto-install on first launch"
echo "  - To use extensions in private browsing: about:addons → extension → Allow in private windows"
echo ""

# Check for GnuPG at the very end so it's the last thing displayed
PRIVATE_GNUPG="$HOME/Private/gnupg"
GNUPG_TARGET="$HOME/.gnupg"

if [ -d "$PRIVATE_GNUPG" ] && [ ! -e "$GNUPG_TARGET" ]; then
    echo "⚠️  IMPORTANT: GnuPG Keys Found"
    echo ""
    echo "Your GnuPG keys are in ~/Private/gnupg but not linked to ~/.gnupg"
    echo "To enable GPG commit signing, run:"
    echo ""
    echo "  ln -s ~/Private/gnupg ~/.gnupg"
    echo ""
fi
