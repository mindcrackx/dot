#!bash
# ~/.bashrc — dot-Loader (Symlink auf dieses File, gelegt von install.sh).
#
# Reihenfolge:
#   1) bash/core.sh              — portabler, gehaerteter Kern
#   2) profiles/$DOT_PROFILE.sh  — server | desktop (maschinen-Rolle)
#   3) ~/.bash_personal / _private / _work — rein lokal, nie im Repo
#
# DOT_DIR wird aus dem Symlink-Ziel dieses Files abgeleitet, funktioniert
# also unabhaengig davon, wohin das Repo geklont wurde.

# nur interaktiv
case $- in *i*) ;; *) return ;; esac

# --- Repo-Verzeichnis bestimmen (Symlink aufloesen) ---
_dot_src="${BASH_SOURCE[0]}"
if command -v readlink >/dev/null 2>&1; then
  _dot_real="$(readlink -f "$_dot_src" 2>/dev/null)"
fi
[ -z "${_dot_real:-}" ] && _dot_real="$_dot_src"
DOT_DIR="$(cd "$(dirname "$_dot_real")" 2>/dev/null && pwd)"
# Fallback auf die klassische rwxrob-Ablage
[ -r "$DOT_DIR/bash/core.sh" ] || DOT_DIR="$HOME/Repos/github.com/mindcrackx/dot"
export DOT_DIR
unset _dot_src _dot_real

# --- Profil bestimmen: Marker-Datei, sonst Auto-Detect (Server als sichere Default) ---
DOT_PROFILE="$(cat "$HOME/.config/dot/profile" 2>/dev/null)"
if [ -z "$DOT_PROFILE" ]; then
  if [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then DOT_PROFILE=desktop; else DOT_PROFILE=server; fi
fi
export DOT_PROFILE

# --- 1) Kern ---
[ -r "$DOT_DIR/bash/core.sh" ] && . "$DOT_DIR/bash/core.sh"

# --- 2) Profil ---
[ -r "$DOT_DIR/profiles/$DOT_PROFILE.sh" ] && . "$DOT_DIR/profiles/$DOT_PROFILE.sh"

# --- 3) lokale, nicht versionierte Ergaenzungen ---
for _f in "$HOME/.bash_personal" "$HOME/.bash_private" "$HOME/.bash_work"; do
  [ -r "$_f" ] && . "$_f"
done; unset _f
