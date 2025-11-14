# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# ---------------------- local utility functions ---------------------

_have()      { type "$1" &>/dev/null; }
_source_if() { [[ -r "$1" ]] && source "$1"; }

# ----------------------- environment variables ----------------------

export USER="${USER:-$(whoami)}"
export GITUSER="mindcrackx"
export REPOS="$HOME/Repos"
export GHREPOS="$REPOS/github.com/$GITUSER"
export DOTFILES="$GHREPOS/dot"
export SCRIPTS="$DOTFILES/scripts"
export SNIPPETS="$DOTFILES/snippets"
export ZETDIR="$GHREPOS/zet"

# Standard directories
export DESKTOP="$HOME/Desktop"
export DOCUMENTS="$HOME/Documents"
export DOWNLOADS="$HOME/Downloads"
export TEMPLATES="$HOME/Templates"
export PUBLIC="$HOME/Public"
export PRIVATE="$HOME/Private"
export PICTURES="$HOME/Pictures"
export MUSIC="$HOME/Music"
export VIDEOS="$HOME/Videos"

# Editor and terminal
export EDITOR=vi
export VISUAL=vi
export EDITOR_PREFIX=vi
export HELP_BROWSER=lynx
export TERM=xterm-256color

# Go configuration
export GOPRIVATE="github.com/$GITUSER/*,gitlab.com/$GITUSER/*"
export GOPATH="$HOME/.local/share/go"
export GOBIN="$HOME/.local/bin"
export GOPROXY=direct
export CGO_ENABLED=0

# Python
export PYTHONDONTWRITEBYTECODE=2

# Locale
export LC_COLLATE=C

# Better less colors for man pages
export LESS_TERMCAP_mb="[35m" # magenta
export LESS_TERMCAP_md="[33m" # yellow
export LESS_TERMCAP_me="" # "0m"
export LESS_TERMCAP_se="" # "0m"
export LESS_TERMCAP_so="[34m" # blue
export LESS_TERMCAP_ue="" # "0m"
export LESS_TERMCAP_us="[4m"  # underline

# Ansible (if you use it)
export ANSIBLE_CONFIG="$HOME/.config/ansible/config.ini"
export ANSIBLE_INVENTORY="$HOME/.config/ansible/inventory.yaml"
export ANSIBLE_LOAD_CALLBACK_PLUGINS=1

# ------------------------------- pager ------------------------------

if [[ -x /usr/bin/lesspipe ]]; then
  export LESSOPEN="| /usr/bin/lesspipe %s";
  export LESSCLOSE="/usr/bin/lesspipe %s %s";
fi

# ----------------------------- dircolors ----------------------------

if _have dircolors; then
  if [[ -r "$HOME/.dircolors" ]]; then
    eval "$(dircolors -b "$HOME/.dircolors")"
  else
    eval "$(dircolors -b)"
  fi
fi

# ------------------------------- path -------------------------------

pathappend() {
  declare arg
  for arg in "$@"; do
    test -d "$arg" || continue
    PATH=${PATH//":$arg:"/:}
    PATH=${PATH/#"$arg:"/}
    PATH=${PATH/%":$arg"/}
    export PATH="${PATH:+"$PATH:"}$arg"
  done
} && export -f pathappend

pathprepend() {
  for arg in "$@"; do
    test -d "$arg" || continue
    PATH=${PATH//:"$arg:"/:}
    PATH=${PATH/#"$arg:"/}
    PATH=${PATH/%":$arg"/}
    export PATH="$arg${PATH:+":${PATH}"}"
  done
} && export -f pathprepend

# Remember: last arg will be first in path
pathprepend \
  "$HOME/.local/bin" \
  "$GOPATH/bin" \
  /usr/local/go/bin \
  "$SCRIPTS"

# Add cmd-* repos if they exist
if [[ -d "$GHREPOS" ]]; then
  for cmd_dir in "$GHREPOS"/cmd-*; do
    [[ -d "$cmd_dir" ]] && pathprepend "$cmd_dir"
  done
fi

# ------------------------------ cdpath ------------------------------

export CDPATH=".:$GHREPOS:$DOTFILES:$REPOS:/media/$USER:$HOME"

# ------------------------ bash shell options ------------------------

shopt -s checkwinsize
shopt -s expand_aliases
shopt -s globstar
shopt -s dotglob
shopt -s extglob

# -------------------------- stty annoyances -------------------------

stty stop undef # disable control-s accidental terminal stops

# ----------------------------- vim mode -----------------------------

set -o vi

# ----------------------------- keyboard -----------------------------

_have setxkbmap && test -n "$DISPLAY" && \
  setxkbmap -option caps:escape &>/dev/null

# Set keyboard layout (change 'de' to your preferred layout)
# Uncomment if needed:
# setxkbmap de > /dev/null 2>&1

# ------------------------------ aliases -----------------------------

# Omarchy provides: ls (eza), cd (zoxide), g (git), d (docker), n (nvim)
# Add your own aliases here or override Omarchy defaults

# Navigation
alias dot='cd $DOTFILES'
alias scripts='cd $SCRIPTS'
alias snippets='cd $SNIPPETS'

# Utilities
alias free='free -h'
alias df='df -h'
alias chmox='chmod u+x'
alias diff='diff --color'
alias temp='cd $(mktemp -d)'
alias view='vi -R'
alias c='printf "\e[H\e[2J"'
alias clear='printf "\e[H\e[2J"'

# ----------------------------- functions ----------------------------

# Load environment variables from .env file
envx() {
  local envfile="${1:-"$HOME/.env"}"
  [[ ! -e "$envfile" ]] && echo "$envfile not found" && return 1
  while IFS= read -r line; do
    name=${line%%=*}
    value=${line#*=}
    [[ -z "${name}" || $name =~ ^# ]] && continue
    export "$name"="$value"
  done < "$envfile"
} && export -f envx

# Auto-load ~/.env if it exists
[[ -e "$HOME/.env" ]] && envx "$HOME/.env"

# Create new GitHub repo from template
new-from() {
  local template="$1"
  local name="$2"
  ! _have gh && echo "gh command not found" && return 1
  [[ -z "$name" ]] && echo "usage: $0 <name>" && return 1
  [[ -z "$GHREPOS" ]] && echo "GHREPOS not set" && return 1
  [[ ! -d "$GHREPOS" ]] && echo "Not found: $GHREPOS" && return 1
  cd "$GHREPOS" || return 1
  [[ -e "$name" ]] && echo "exists: $name" && return 1
  gh repo create -p "$template" --private "$name"
  cd "$name" || return 1
}

new-bonzai() { new-from rwxrob/bonzai-template "bonzai-$1"; }
new-cmd() { new-from rwxrob/template-bash-command "cmd-$1"; }

export -f new-from new-bonzai new-cmd

# Clone GitHub repos to organized structure
clone() {
  local repo="$1" user
  local repo="${repo#https://github.com/}"
  local repo="${repo#git@github.com:}"
  if [[ $repo =~ / ]]; then
    user="${repo%%/*}"
  else
    user="$GITUSER"
    [[ -z "$user" ]] && user="$USER"
  fi
  local name="${repo##*/}"
  local userd="$REPOS/github.com/$user"
  local path="$userd/$name"
  [[ -d "$path" ]] && cd "$path" && return
  mkdir -p "$userd"
  cd "$userd"
  echo gh repo clone "$user/$name" -- --recurse-submodule
  gh repo clone "$user/$name" -- --recurse-submodule
  cd "$name"
} && export -f clone

# Navigate to zet entries (if you use zet)
cdz() { cd $(zet get "$@"); }
export -f cdz

# ------------- source external dependencies / completion ------------

# GitHub CLI
_have gh && . <(gh completion -s bash)

# Kubernetes
_have kubectl && . <(kubectl completion bash 2>/dev/null)
_have k && complete -o default -F __start_kubectl k

# Container tools
_have kind && . <(kind completion bash)
_have helm && . <(helm completion bash)
_have minikube && . <(minikube completion bash)
_have mk && complete -o default -F __start_minikube mk

# Docker/Podman completions
_source_if "$HOME/.local/share/podman/completion"
_source_if "$HOME/.local/share/docker/completion"

# Terraform
_have terraform && complete -C /usr/bin/terraform terraform
_have terraform && complete -C /usr/bin/terraform tf

# Ansible
_have ansible && . <(register-python-argcomplete3 ansible)
_have ansible-playbook && . <(register-python-argcomplete3 ansible-playbook)
_have ansible-galaxy && . <(register-python-argcomplete3 ansible-galaxy)
_have ansible-vault && . <(register-python-argcomplete3 ansible-vault)

# Other tools
_have hcloud && . <(hcloud completion bash)
_have pandoc && . <(pandoc --bash-completion)

# -------------------- personalized configuration --------------------

# Source personal configs if they exist
[[ -f "$HOME/.bash_personal" ]] && source "$HOME/.bash_personal"
[[ -f "$HOME/.bash_private" ]] && source "$HOME/.bash_private"
[[ -f "$HOME/.bash_work" ]] && source "$HOME/.bash_work"
