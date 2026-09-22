#!/usr/bin/env bash
# Regenera las listas de apps y recopia configs vivas al repo (usado por sync.sh e install.sh)
set -euo pipefail
DOT="${DOTFILES_DIR:-$HOME/dotfiles}"
cd "$DOT"

mkdir -p packages

# 1. Listas de paquetes
pacman -Qqe > packages/pkglist-explicit.txt 2>/dev/null || true
if command -v yay >/dev/null 2>&1; then
  yay -Qqm > packages/pkglist-aur.txt 2>/dev/null || true
fi
if command -v mise >/dev/null 2>&1; then
  mise ls > packages/mise-list.txt 2>&1 || true
fi
if command -v code >/dev/null 2>&1; then
  code --list-extensions > packages/vscode-extensions.txt 2>&1 || true
fi
if command -v uv >/dev/null 2>&1; then
  uv tool list > packages/uv-tools.txt 2>&1 || true
fi

# 2. Recopiar configs vivas -> árbol stow (sobrescribe repo con sistema)
# Si el origen ya es un symlink al repo (máquina con stow aplicado),
# no hay nada que recopiar: los cambios ya caen directo en el repo.
in_repo() { # $1=ruta -> 0 si resuelve dentro de $DOT
  local r
  r="$(readlink -f "$1" 2>/dev/null)" || return 1
  case "$r" in "$DOT"/*) return 0 ;; *) return 1 ;; esac
}
copy() { # $1=origen $2=destino
  if [ -e "$1" ] || [ -L "$1" ]; then
    in_repo "$1" && return 0
    mkdir -p "$(dirname "$2")"; cp -a "$1" "$2"
  fi
}
copy "$HOME/.bashrc"              "$DOT/bash/.bashrc"
copy "$HOME/.bash_profile"        "$DOT/bash/.bash_profile"
copy "$HOME/.profile"             "$DOT/bash/.profile"
copy "$HOME/.config/git/config"   "$DOT/git/.config/git/config"
copy "$HOME/.config/starship.toml" "$DOT/starship/.config/starship.toml"
copy "$HOME/.config/ghostty/config" "$DOT/ghostty/.config/ghostty/config"
copy "$HOME/.config/mise/config.toml" "$DOT/mise/.config/mise/config.toml"
copy "$HOME/.config/tmux/tmux.conf" "$DOT/tmux/.config/tmux/tmux.conf"
copy "$HOME/.config/Code/User/settings.json"    "$DOT/vscode/.config/Code/User/settings.json"
copy "$HOME/.config/Code/User/keybindings.json" "$DOT/vscode/.config/Code/User/keybindings.json"
copy "$HOME/.config/opencode/opencode.json" "$DOT/opencode/.config/opencode/opencode.json"

# dirs completos (rsync si existe, si no cp)
sync_dir() { # $1=origen $2=destino
  [ -d "$1" ] || return 0
  in_repo "$1" && return 0
  mkdir -p "$2"
  if command -v rsync >/dev/null 2>&1; then
    rsync -aL --exclude '*.bak.*' --exclude '*.bak' --exclude '.omaplug-menu.lock' "$1/" "$2/"
  else
    cp -a "$1/." "$2/"
  fi
}
sync_dir "$HOME/.config/hypr" "$DOT/hypr/.config/hypr"
sync_dir "$HOME/.config/nvim" "$DOT/nvim/.config/nvim"
# theme.lua de nvim es un symlink dinámico de Omarchy (-> ~/.local/state/...)
# que cuelga fuera del repo: no versionarlo ni dejar que stow lo toque
# (ver nvim/.stow-local-ignore)
rm -f "$DOT/nvim/.config/nvim/lua/plugins/theme.lua"
sync_dir "$HOME/.config/fish/conf.d" "$DOT/fish/.config/fish/conf.d"

# omarchy: solo ficheros core + extensiones + plugins propios (niistal.* / admin.*)
mkdir -p "$DOT/omarchy/.config/omarchy/plugins" "$DOT/omarchy/.config/omarchy/extensions"
for f in shell.json shell.toml mousemap.json; do
  copy "$HOME/.config/omarchy/$f" "$DOT/omarchy/.config/omarchy/$f"
done
sync_dir "$HOME/.config/omarchy/extensions" "$DOT/omarchy/.config/omarchy/extensions"
# NOTA: no borrar el dir antes del rsync. Con stow aplicado, los ficheros
# vivos son symlinks a este mismo dir; un rm -rf dejaría los links colgando
# y el rsync fallaría. Sin --delete, los plugins eliminados en vivo quedan
# como ficheros huérfanos visibles en `git status` para poda manual.
mkdir -p "$DOT/omarchy/.config/omarchy/plugins"
for d in "$HOME"/.config/omarchy/plugins/niistal.* "$HOME"/.config/omarchy/plugins/admin.*; do
  [ -e "$d" ] || continue
  base="$(basename "$d")"
  mkdir -p "$DOT/omarchy/.config/omarchy/plugins/$base"
  if command -v rsync >/dev/null 2>&1; then
    rsync -aL --exclude '*.bak.*' "$d/" "$DOT/omarchy/.config/omarchy/plugins/$base/"
  else
    cp -a "$d/." "$DOT/omarchy/.config/omarchy/plugins/$base/"
  fi
done

# 3. Sanitizar secretos comunes (helper gh con ruta absoluta -> portable)
sed -i 's|helper = !.*gh auth git-credential|helper = !gh auth git-credential|' "$DOT/git/.config/git/config" 2>/dev/null || true

echo "[dump] OK $(date -u +%FT%TZ)"
