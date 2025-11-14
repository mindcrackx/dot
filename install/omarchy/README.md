# Omarchy Setup

Opinionated setup scripts for [Omarchy](https://omarchy.org/) (Arch Linux distribution).

## Quick Start

```bash
cd ~/Repos/github.com/mindcrackx/dot/install/omarchy
./install.sh
```

## What Gets Installed

### Applications
- **Claude Code** - Official Anthropic CLI for Claude
- **Firefox** - Browser with custom policies and extensions
- **Ghostty** - Modern GPU-accelerated terminal
- **KeePassXC** - Password manager
- **Tailscale** - VPN mesh network
- **VSCode** - Code editor with settings
- **tmux** - Terminal multiplexer

### Dotfiles
- **Scripts** - Utility scripts symlinked to `~/Scripts`
- **.bashrc** - Bash configuration (Omarchy-specific)
- **.inputrc** - Readline configuration with vi mode
- **.gitconfig** - Git configuration (symlinked to `~/Private/.gitconfig`)

### Hyprland Overrides
- Monitor scaling (1.2x)
- Claude.ai instead of ChatGPT (Super+Shift+A)
- YouTube in Firefox (Super+Shift+Y)
- KeePassXC binding (Super+Shift+K)
- Natural scrolling for touchpad

## Individual Scripts

Run scripts individually if you only need specific components:

```bash
./install-claude-code.sh   # Install Claude Code
./install-firefox.sh        # Install Firefox with policies
./install-ghostty.sh        # Install Ghostty terminal
./install-keepassxc.sh      # Install KeePassXC
./install-tailscale.sh      # Install Tailscale + tsui
./install-vscode.sh         # Install VSCode
./install-tmux.sh           # Install tmux
./install-dotfiles.sh       # Symlink Scripts, .bashrc, .inputrc
./install-overrides.sh      # Add Hyprland overrides
```

## Post-Installation

### Enable vim mode in Claude Code
```bash
/config
```

### Firefox Extensions
Extensions auto-install on first launch. To use in private browsing:
1. Open `about:addons`
2. Click on extension
3. Enable "Allow in private windows"

### KeePassXC Setup
Open KeePassXC and set up browser integration:
1. Open KeePassXC (Super+Shift+K)
2. Create or open your database
3. Go to Settings → Browser Integration
4. Check "Enable browser integration"
5. In Firefox, click the KeePassXC-Browser extension icon
6. Click "Connect" to link it to your database

### Tailscale
Connect to your network:
```bash
sudo tailscale up
```

Or use the TUI:
```bash
sudo tsui
```

## Scripts in ~/Scripts

Your utility scripts are available in PATH:
- `vi` - Opens nvim (or vim/vi as fallback)
- `ll` - Better ls with eza (colored, icons)
- `g` - Git shorthand (finds real git, not the script)
- `k` - kubectl shorthand
- `d` - Docker shorthand
- `h` - Helm shorthand
- Plus 30+ other utilities (see `~/Scripts/`)

## Git Configuration

Git config is managed in `~/Private/.gitconfig` and symlinked to `~/.gitconfig`.

**Features:**
- GPG commit signing enabled
- Modern defaults (main branch, rebase on pull)
- Better diff visualization (histogram algorithm, moved code highlighting)
- Comprehensive aliases (glog, glola, st, co, etc.)
- Smart sorting (recent branches first)
- Conflict resolution memory (rerere)

**Edit your config:**
```bash
vi ~/Private/.gitconfig
```

Set your personal information:
- `user.email` - Your email
- `user.name` - Your name
- `user.signingkey` - Your GPG key ID

## GnuPG Keys

If you have GnuPG keys in `~/Private/gnupg`, the install script will notify you to link them.

**Link your keys:**
```bash
ln -s ~/Private/gnupg ~/.gnupg
```

This keeps your GPG keys in the Private folder (which can be excluded from backups or kept on encrypted storage) while making them available to git and other tools.

## KeePassXC Password Manager

KeePassXC is configured with secure defaults and browser integration.

**Configuration:** `~/.config/keepassxc/keepassxc.ini` (symlinked to dotfiles)

**Security Features:**
- Auto-lock after 5 minutes of inactivity
- Auto-lock on screen lock/user switch
- Clipboard auto-clear after 10 seconds
- Window blocked from screen sharing (Hyprland security rule)
- Database auto-save and backup before save

**Browser Integration:**
- Firefox extension (KeePassXC-Browser) auto-installs
- Enable in KeePassXC: Settings → Browser Integration
- Supports autofill for websites

**Database Location:**
Store your .kdbx database in `~/Private/` to keep it with your other sensitive files.

**Keybinding:**
- `Super + Shift + K` - Launch KeePassXC

**Password Generator Defaults:**
- 20 characters
- Includes uppercase, lowercase, numbers, special characters
- Excludes look-alike characters (0/O, 1/l, etc.)

**Edit config:**
```bash
vi ~/Repos/github.com/mindcrackx/dot/install/omarchy/keepassxc.ini
```

Changes take effect on next KeePassXC launch.

## Customization

### Bash Configuration
Edit `~/.bashrc` (symlinked from this directory) to customize:
- Environment variables
- Aliases
- Functions
- Completions

Personal configs are sourced automatically:
- `~/.bash_personal` - Personal customizations
- `~/.bash_private` - Private/sensitive config
- `~/.bash_work` - Work-specific config

### Hyprland
Edit `omarchy-overrides.conf` in this directory, changes take effect on next Hyprland reload.

## Updating

To update applications:
```bash
yay -Syu
```

To update dotfiles:
```bash
cd ~/Repos/github.com/mindcrackx/dot
git pull
```

## Troubleshooting

### Scripts not in PATH
Restart your shell or run:
```bash
source ~/.bashrc
```

### Permissions issues
Make sure scripts are executable:
```bash
chmod +x ~/Scripts/*
```

### Backup files
Install scripts create `.backup` files if they overwrite existing configs. These are gitignored.
