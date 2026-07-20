#!/usr/bin/env bash
# dot/install.sh — portabler, idempotenter Dotfiles-Installer.
#
#   ./install.sh [--profile server|desktop] [--dry-run]
#
# Legt Symlinks fuer die versionierten Dotfiles an (mit Backup bestehender
# Dateien), bindet die geteilte Git-Config per include ein (ohne Identitaet
# oder Signing anzufassen) und schreibt den Profil-Marker ~/.config/dot/profile.
# Mehrfach ausfuehrbar: bereits korrekte Symlinks werden uebersprungen.
set -euo pipefail

# --- Repo-Verzeichnis (Symlink aufloesen) ---
DOT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# --- Argumente ---
PROFILE=""
DRY_RUN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --profile) PROFILE="${2:-}"; shift 2 ;;
    --profile=*) PROFILE="${1#*=}"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unbekanntes Argument: $1" >&2; exit 2 ;;
  esac
done

# --- Profil bestimmen (Flag > Auto-Detect; Server ist die sichere Default) ---
if [ -z "$PROFILE" ]; then
  if [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then PROFILE=desktop; else PROFILE=server; fi
fi
case "$PROFILE" in
  server|desktop) ;;
  *) echo "Ungueltiges Profil '$PROFILE' (server|desktop)" >&2; exit 2 ;;
esac

echo "=== dot install ==="
echo "  Repo:    $DOT_DIR"
echo "  HOME:    $HOME  (User $(id -un))"
echo "  Profil:  $PROFILE"
[ "$DRY_RUN" = 1 ] && echo "  MODUS:   DRY-RUN (keine Aenderungen)"
echo

_have() { command -v "$1" >/dev/null 2>&1; }

# link <quelle> <ziel>: idempotent, mit Backup bestehender realer Datei/Verzeichnis
link() {
  local src="$1" dst="$2"
  if [ ! -e "$src" ]; then
    echo "  ! Quelle fehlt, ueberspringe: $src"; return 0
  fi
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    echo "  = $dst (bereits verlinkt)"; return 0
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local bak="$dst.pre-dot.$(date +%Y%m%d-%H%M%S).bak"
    echo "  ~ Backup: $dst -> $bak"
    [ "$DRY_RUN" = 1 ] || mv "$dst" "$bak"
  fi
  echo "  + Link:   $dst -> $src"
  if [ "$DRY_RUN" != 1 ]; then
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
  fi
}

# --- 1) Shell-Dotfiles ---
echo "[1] Shell-Konfiguration"
link "$DOT_DIR/.bashrc"        "$HOME/.bashrc"
link "$DOT_DIR/.profile"       "$HOME/.profile"
link "$DOT_DIR/.inputrc"       "$HOME/.inputrc"
link "$DOT_DIR/.dircolors"     "$HOME/.dircolors"
link "$DOT_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
link "$DOT_DIR/scripts"        "$HOME/Scripts"
echo

# --- 2) nvim nur, wenn Neovim installiert ist ---
echo "[2] Neovim"
if _have nvim; then
  link "$DOT_DIR/nvim" "$HOME/.config/nvim"
else
  echo "  - nvim nicht installiert, ueberspringe nvim-Config"
fi
echo

# --- 3) Git: geteilte Config per include einbinden (Identitaet bleibt lokal) ---
echo "[3] Git (include der geteilten Defaults, ohne Identitaet/Signing zu aendern)"
GITSHARED="$DOT_DIR/git/gitconfig-shared.ini"
if _have git && [ -f "$GITSHARED" ]; then
  if git config --global --get-all include.path 2>/dev/null | grep -qxF "$GITSHARED"; then
    echo "  = include.path bereits gesetzt"
  else
    echo "  + git config --global --add include.path $GITSHARED"
    [ "$DRY_RUN" = 1 ] || git config --global --add include.path "$GITSHARED"
  fi
  # sanity: Identitaet vorhanden?
  if ! git config --global user.email >/dev/null 2>&1; then
    echo "  ⚠️  ~/.gitconfig hat keine user.email — bitte setzen:"
    echo "      git config --global user.name  'Dein Name'"
    echo "      git config --global user.email 'du@example.com'"
  fi
else
  echo "  - git oder $GITSHARED nicht vorhanden, ueberspringe"
fi
echo

# --- 4) Profil-Marker ---
echo "[4] Profil-Marker"
echo "  -> $HOME/.config/dot/profile = $PROFILE"
if [ "$DRY_RUN" != 1 ]; then
  mkdir -p "$HOME/.config/dot"
  printf '%s\n' "$PROFILE" > "$HOME/.config/dot/profile"
fi
echo

echo "=== fertig ==="
echo "Neue Shell starten oder:  source ~/.bashrc"
