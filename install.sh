#!/usr/bin/env bash
# Instalador dotfiles (Omarchy/Arch) con GNU Stow
# Uso: git clone https://github.com/Niistal/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
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

echo "==> [2/6] Paquetes de repos oficiales"
if [ -f packages/pkglist-explicit.txt ]; then
  # pkglist-explicit incluye paquetes AUR/extranjeros; pacman solo acepta los de repos.
  # Se filtra restando la lista AUR (si yay/pacman -Qqm disponible) y comprobando con pacman -Si.
  tmp_repo="$(mktemp)"
  if [ -s packages/pkglist-aur.txt ]; then
    comm -23 <(sort -u packages/pkglist-explicit.txt) <(sort -u packages/pkglist-aur.txt) > "$tmp_repo"
  else
    cp packages/pkglist-explicit.txt "$tmp_repo"
  fi
  tmp_ok="$(mktemp)"
  while read -r pkg; do
    [ -n "$pkg" ] || continue
    if pacman -Si "$pkg" >/dev/null 2>&1; then echo "$pkg" >> "$tmp_ok"; else echo "skip (no está en repos, lo cubre el paso AUR): $pkg"; fi
  done < "$tmp_repo"
  sudo pacman -S --needed - < "$tmp_ok" || echo "WARN: algún paquete pacman falló, sigue..."
  rm -f "$tmp_repo" "$tmp_ok"
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
# --adopt: en la máquina origen los ficheros ya existen como reales; adopt los
# mueve al repo y deja symlinks. En máquina nueva no hay conflicto y es no-op.
# --restow permite re-ejecutar sin errores.
stow --adopt --restow bash git starship ghostty hypr nvim omarchy mise tmux fish opencode vscode
# --adopt puede haber movido cambios vivos al repo: se descartan si son
# idénticos en contenido real (solo cambia modo), o se commitean vía sync.
git diff --quiet || { echo "stow adoptó cambios vivos, revísalos con: git -C $DOT status"; }

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
