#!bash
# profiles/desktop.sh — Arbeitsplatz-Rechner mit X/Wayland (Omarchy/Fedora/…).
# Vom Loader NACH bash/core.sh gesourct. Hier lebt alles, was einen
# Grafik-Stack voraussetzt und auf einem Server nichts zu suchen hat.

# CapsLock -> Escape und deutsches Layout (nur unter X; unter Wayland No-op)
if _have setxkbmap && [ -n "${DISPLAY:-}" ]; then
  setxkbmap -option caps:escape &>/dev/null
  setxkbmap de &>/dev/null
fi
# TODO: Wayland-Aequivalent (z.B. hyprland input-config) statt setxkbmap.

export HELP_BROWSER=lynx
