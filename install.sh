#!/usr/bin/env bash
# Instalador dotfiles (Omarchy/Arch) con GNU Stow
# Uso: git clone <repo> ~/dotfiles && ~/dotfiles/install.sh
set -euo pipefail
DOT="$(cd "$(dirname "$0")" && pwd)"
cd "$DOT"

echo "==> [1/6] Paquetes base"
sudo pacman -S --needed --noconfirm git stow rsync openssh 2>&1 | tail -n 3 || true

if ! command -v yay >/dev/null 2>&1; then
  echo "==> instalando yay"
  tmp="$(mktemp -d)"; git clone https://aur.archlinux.org/yay.git "$tmp/yay"
  (cd "$tmp/yay" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi

echo "==> [2/6] Paquetes pacman explícitos"
if [ -f packages/pkglist-explicit.txt ]; then
  sudo pacman -S --needed - < packages/pkglist-explicit.txt || echo "WARN: algún paquete pacman falló, sigue..."
fi

echo "==> [3/6] Paquetes AUR"
if [ -f packages/pkglist-aur.txt ] && [ -s packages/pkglist-aur.txt ]; then
  yay -S --needed - < packages/pkglist-aur.txt || echo "WARN: algún paquete AUR falló, sigue..."
fi

echo "==> [4/6] mise + herramientas"
if [ -f mise/.config/mise/config.toml ]; then
  mkdir -p ~/.config/mise
  cp -a mise/.config/mise/config.toml ~/.config/mise/config.toml 2>/dev/null || true
fi
if command -v mise >/dev/null 2>&1; then
  mise install || echo "WARN: mise install falló parcialmente"
fi

echo "==> [5/6] Stow (symlinks a \$HOME)"
# stow crea symlinks; --restow para re-ejecutar sin errores
stow --restow bash git starship ghostty hypr nvim omarchy mise tmux fish opencode vscode

echo "==> [6/6] Extensiones VSCode + autosync"
if [ -f packages/vscode-extensions.txt ] && command -v code >/dev/null 2>&1; then
  while read -r ext; do [ -n "$ext" ] && code --install-extension "$ext" --force >/dev/null 2>&1 || true; done < packages/vscode-extensions.txt
  echo "extensiones VSCode restauradas"
fi

mkdir -p ~/.config/systemd/user
cp -a systemd/dotfiles-autosync.service systemd/dotfiles-autosync.timer ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now dotfiles-autosync.timer
# atajo manual
if ! grep -q 'dotfiles-sync' ~/.bashrc 2>/dev/null; then
  printf '\n# dotfiles sync manual\nalias dotfiles-sync="$HOME/dotfiles/scripts/sync.sh"\n' >> ~/.bashrc
fi

echo ""
echo "OK. Instalado. Comprueba: stow --restow <pkg>, systemctl --user status dotfiles-autosync.timer"
echo "Sync manual: ~/dotfiles/scripts/sync.sh (o alias dotfiles-sync tras recargar shell)"
