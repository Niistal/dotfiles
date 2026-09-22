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
copy() { # $1=origen $2=destino
  if [ -e "$1" ]; then mkdir -p "$(dirname "$2")"; cp -a "$1" "$2"; fi
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
  mkdir -p "$2"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete --exclude '*.bak.*' --exclude '*.bak' --exclude '.omaplug-menu.lock' "$1/" "$2/"
  else
    cp -a "$1/." "$2/"
  fi
}
sync_dir "$HOME/.config/hypr" "$DOT/hypr/.config/hypr"
sync_dir "$HOME/.config/nvim" "$DOT/nvim/.config/nvim"
sync_dir "$HOME/.config/fish/conf.d" "$DOT/fish/.config/fish/conf.d"

# omarchy: solo ficheros core + extensiones + plugins propios (niistal.* / admin.*)
mkdir -p "$DOT/omarchy/.config/omarchy/plugins" "$DOT/omarchy/.config/omarchy/extensions"
for f in shell.json shell.toml mousemap.json; do
  copy "$HOME/.config/omarchy/$f" "$DOT/omarchy/.config/omarchy/$f"
done
sync_dir "$HOME/.config/omarchy/extensions" "$DOT/omarchy/.config/omarchy/extensions"
rm -rf "$DOT/omarchy/.config/omarchy/plugins"
mkdir -p "$DOT/omarchy/.config/omarchy/plugins"
for d in "$HOME"/.config/omarchy/plugins/niistal.* "$HOME"/.config/omarchy/plugins/admin.*; do
  [ -e "$d" ] || continue
  base="$(basename "$d")"
  mkdir -p "$DOT/omarchy/.config/omarchy/plugins/$base"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete --exclude '*.bak.*' "$d/" "$DOT/omarchy/.config/omarchy/plugins/$base/"
  else
    cp -a "$d/." "$DOT/omarchy/.config/omarchy/plugins/$base/"
  fi
done

# 3. Sanitizar secretos comunes (helper gh con ruta absoluta -> portable)
sed -i 's|helper = !.*gh auth git-credential|helper = !gh auth git-credential|' "$DOT/git/.config/git/config" 2>/dev/null || true

echo "[dump] OK $(date -u +%FT%TZ)"
