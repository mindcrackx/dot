# dot

Portable Dotfiles für **alle meine Maschinen** — headless-Server (Homelab-LXCs)
und Desktops (Omarchy/Fedora) aus **einer** Quelle. Der Shell-Kern ist
maschinen-agnostisch und gehärtet (nichts bricht, wenn ein Tool fehlt);
maschinen-Rollen kommen über **Profile** dazu.

## Schnellstart (neue Maschine)

```sh
export GITUSER=mindcrackx
mkdir -p ~/Repos/github.com/$GITUSER
git clone git@github.com:$GITUSER/dot ~/Repos/github.com/$GITUSER/dot
cd ~/Repos/github.com/$GITUSER/dot
sudo ./install/core-packages.sh    # Core-CLI-Tools (vim, htop, tree, fzf, pcre2grep …)
./install.sh --profile server      # Symlinks + Profil (oder: --profile desktop)
source ~/.bashrc
```

`install.sh` ist **idempotent** und legt von bestehenden Dateien vorher ein
`*.pre-dot.<zeit>.bak` an. `--profile` weglassen → Auto-Detect
(X/Wayland vorhanden → `desktop`, sonst `server`). `--dry-run` zeigt nur, was
passieren würde.

## Aufbau

```
.bashrc                  # Loader: bestimmt DOT_DIR + Profil, sourct in Reihenfolge:
bash/core.sh             #   1) portabler, gehärteter Kern (Prompt mit git-branch + kubectl-ctx,
                         #      PATH, History, Completions, Funktionen). Aliase, die ein Tool
                         #      brauchen/shadowen, sind per `_have` abgesichert.
profiles/server.sh       #   2a) headless-Server (kein X) — schlank
profiles/desktop.sh      #   2b) Desktop (X/Wayland: setxkbmap, HELP_BROWSER …)
~/.bash_personal         #   3) rein lokal, NICHT im Repo — pro Maschine Einzigartiges
git/gitconfig-shared.ini # geteilte Git-Defaults + Aliases (KEIN [user], KEIN erzwungenes Signing)
scripts/                 # ~40 kleine exec-Wrapper (k, g, d, ll, vi …) → ~/Scripts
.inputrc .dircolors tmux/.tmux.conf .profile
nvim/                    # nur verlinkt, wenn nvim installiert ist
install/core-packages.sh # Core-CLI-Tools für JEDE Maschine (cross-distro apt/dnf/pacman)
install/                 # ältere, distro-spezifische Setup-Skripte (fedora/ubuntu/omarchy)
```

## Prinzipien

- **Server darf nichts brechen:** jeder Alias/Seiteneffekt, der ein
  Nicht-Coreutil-Tool voraussetzt oder ein echtes Kommando überdeckt
  (`grep`, `top` …), steht hinter `_have`. Desktop-Zwänge (Tastatur-Remap
  etc.) leben ausschließlich in `profiles/desktop.sh`.
- **Identität bleibt lokal:** `install.sh` bindet `git/gitconfig-shared.ini`
  nur per `[include]` in `~/.gitconfig` ein und fasst `user.*`/Signing nie an.
  Headless-Server committen **unsigniert**; Desktops signieren lokal
  (z. B. via `~/Private/.gitconfig`).
- **Ein Repo, viele Maschinen:** Rollen über Profile, Maschinen-Spezifika über
  `~/.bash_personal`.

## Profil wechseln

```sh
echo desktop > ~/.config/dot/profile && source ~/.bashrc
```

> Hinweis: Das ältere Top-Level-`setup` (und `install/omarchy/install-dotfiles.sh`)
> bleiben für Bestands-Setups erhalten; für neue Maschinen ist `install.sh`
> der empfohlene Weg.
