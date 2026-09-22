# dotfiles (Omarchy/Arch, GNU Stow, privado)

Config personal: bash, git, starship, ghostty, hypr, nvim, omarchy (shell.json + plugins `niistal.*`/`admin.*`), mise, tmux, fish, opencode, vscode + listas de apps.

## Estructura

Cada carpeta es un paquete stow que se enlaza a `$HOME`:

| paquete | destino |
|---|---|
| `bash/` | `~/.bashrc`, `~/.bash_profile`, `~/.profile` |
| `git/` | `~/.config/git/config` |
| `starship/` | `~/.config/starship.toml` |
| `ghostty/` | `~/.config/ghostty/config` |
| `hypr/` | `~/.config/hypr/` |
| `nvim/` | `~/.config/nvim/` |
| `omarchy/` | `~/.config/omarchy/{shell.json,shell.toml,mousemap.json,extensions/,plugins/niistal.*+admin.*}` |
| `mise/` | `~/.config/mise/config.toml` |
| `tmux/` | `~/.config/tmux/tmux.conf` |
| `fish/` | `~/.config/fish/conf.d/` |
| `opencode/` | `~/.config/opencode/opencode.json` |
| `vscode/` | `~/.config/Code/User/{settings,keybindings}.json` |
| `packages/` | `pkglist-explicit.txt` (pacman), `pkglist-aur.txt` (yay), `vscode-extensions.txt`, `mise-list.txt`, `uv-tools.txt` |

## Instalación en máquina nueva

```bash
git clone https://github.com/Niistal/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Hace: instala `stow`/`yay`, restaura paquetes pacman+AUR, `mise install`, `stow --restow ...`, extensiones VSCode, y activa el timer de autosync.

## Autosync (sin mantenimiento manual)

- `scripts/dump.sh` — recopia tu sistema vivo al repo + regenera listas de apps (sanitiza el helper de `gh`).
- `scripts/sync.sh` — `dump` + `commit "autosync <UTC>"` + `push` solo si hay cambios.
- `systemd/dotfiles-autosync.{service,timer}` — corre `sync.sh` cada hora (+5 min tras arrancar).

El `install.sh` ya lo deja activado. Estado:

```bash
systemctl --user status dotfiles-autosync.timer
journalctl --user -u dotfiles-autosync.service -n 30
~/dotfiles/scripts/sync.sh   # sync manual
```

## Notas

- Repo **privado**: contiene email (`nistal.iker@uni.eus` en git config) y nombres de proyecto. Revisa `git log` antes de hacerlo público.
- Omarchy: solo se versionan tus plugins propios (`niistal.*`, `admin.*`), no todo el upstream.
- Lo que NO se sincroniza a propósito: `~/.ssh`, `~/.gnupg`, tokens, cachés, `.bak.*`.
