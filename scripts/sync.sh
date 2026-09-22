#!/usr/bin/env bash
# Autosync: dump + commit + push si hay cambios. Lo ejecuta el timer systemd o manual: dotfiles-sync
set -euo pipefail
DOT="${DOTFILES_DIR:-$HOME/dotfiles}"
cd "$DOT"

bash "$DOT/scripts/dump.sh"

git add -A
if git diff --cached --quiet; then
  echo "[sync] sin cambios"
  exit 0
fi

git commit -m "autosync $(date -u +%FT%TZ)" >/dev/null
echo "[sync] commit creado, haciendo push..."
if git push; then
  echo "[sync] push OK"
else
  echo "[sync] push FALLÓ (¿sin red? se reintentará en el próximo tick)" >&2
  exit 1
fi
