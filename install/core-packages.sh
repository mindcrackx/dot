#!/usr/bin/env bash
# dot/install/core-packages.sh — Core-CLI-Tools, die die Dotfiles/Aliase
# erwarten, auf JEDER Maschine. Cross-distro (apt/dnf/pacman), idempotent
# (der Paketmanager ueberspringt bereits Installiertes). Braucht root —
# nutzt sudo, falls nicht als root gestartet.
#
#   ./core-packages.sh [--dry-run]
#
# Ergaenzendes/Optionales (nmap-Spielereien, figlet, lynx, build-tooling)
# steht weiterhin in install/<distro>/install-most-stuff-*.
set -euo pipefail

DRY_RUN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unbekanntes Argument: $1" >&2; exit 2 ;;
  esac; shift
done

# Distro-unabhaengig gleich benannte Core-Pakete
CORE_COMMON="git tmux curl wget tree htop jq ripgrep fzf less sshpass make entr shellcheck nmap bash-completion ca-certificates"

SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

# Paketmanager erkennen + die divergent benannten Pakete mappen
#   vim : dnf heisst es vim-enhanced
#   pcre-grep : Debian13/Fedora liefern nur noch PCRE2 (pcre2grep)
if command -v apt-get >/dev/null 2>&1; then
  MGR=apt;    VIM=vim;          PCRE=pcre2-utils
elif command -v dnf >/dev/null 2>&1; then
  MGR=dnf;    VIM=vim-enhanced; PCRE=pcre2-tools
elif command -v pacman >/dev/null 2>&1; then
  MGR=pacman; VIM=vim;          PCRE=pcre2
else
  echo "Kein unterstuetzter Paketmanager (apt/dnf/pacman) gefunden." >&2
  exit 1
fi

PKGS="$VIM $CORE_COMMON $PCRE"
echo "=== dot core-packages ==="
echo "  Paketmanager: $MGR"
echo "  Pakete:       $PKGS"
[ "$DRY_RUN" = 1 ] && { echo "  (dry-run — keine Installation)"; exit 0; }
echo

case "$MGR" in
  apt)
    $SUDO apt-get update -qq
    # shellcheck disable=SC2086
    $SUDO apt-get install -y $PKGS
    ;;
  dnf)
    # shellcheck disable=SC2086
    $SUDO dnf install -y $PKGS
    ;;
  pacman)
    # shellcheck disable=SC2086
    $SUDO pacman -S --needed --noconfirm $PKGS
    ;;
esac

echo
echo "=== fertig — neue Shell starten (Aliase greifen dann: grep->pcre2grep, vi->vim, tree ...) ==="
