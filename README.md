# Omarchy Dotfiles — Reproducible Linux & DevOps Workstation

> **Declarative, reproducible workstation configuration for Arch Linux / Omarchy powered by GNU Stow, Hyprland, Neovim, Ghostty, Starship, and Mise.**

[![Platform: Arch Linux](https://img.shields.io/badge/Platform-Arch_Linux_%7C_Omarchy-1793D1?style=flat-square&logo=archlinux)](#)
[![Window Manager: Hyprland](https://img.shields.io/badge/WM-Hyprland_%7C_Wayland-00B4D8?style=flat-square)](#)
[![Editor: Neovim](https://img.shields.io/badge/Editor-Neovim_%7C_Lua-57A143?style=flat-square&logo=neovim)](#)
[![Manager: GNU Stow](https://img.shields.io/badge/Dotfiles-GNU_Stow-18181B?style=flat-square)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-gray?style=flat-square)](LICENSE)

---

## 🖥️ Workstation Philosophy & Ecosystem

This repository manages my daily engineering environment across development machines. It emphasizes:
- **Instant Reproducibility:** From a bare Arch Linux install to a fully operational development workstation in under 10 minutes.
- **Declarative Symlinking:** Using GNU Stow packages to isolate application configurations without polluting `$HOME`.
- **Keyboard-Driven Workflow:** Unified Vim keybindings across window management (Hyprland), text editing (Neovim), terminal multiplexing (tmux), and shell navigation (Fish / Starship).

---

## 📦 Modular Component Packages

| Module | Core Tool | Configuration Focus |
|---|---|---|
| **`hyprland/`** | Hyprland + Waybar | Smooth 144Hz Wayland compositing, dynamic window tiling, fractional scaling, and scratchpad management. |
| **`nvim/`** | Neovim 0.10+ (Lua) | Lazy.nvim package manager, Treesitter syntax parsing, LSP zero-config (Rust, Python, TypeScript, C#). |
| **`ghostty/`** | Ghostty Terminal | GPU-accelerated terminal emulation, native tabs, true-color rendering. |
| **`fish/`** | Fish Shell + Starship | Blazing fast prompt, autosuggestions, syntax highlighting, and custom aliases. |
| **`mise/`** | Mise (asdf replacement) | Deterministic runtime version management (`rustc`, `python`, `node`, `go`). |
| **`tmux/`** | Tmux Multiplexer | Session resurrection, vim-tmux-navigator integration, persistent terminal sessions. |
| **`git/`** | Git 2.45+ | Histogram diff algorithm, automatic upstream tracking, signed commits, and rebase workflow. |

---

## 🚀 Bootstrap & Installation

```bash
# 1. Clone dotfiles repository into ~/.dotfiles
git clone https://github.com/Niistal/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Inspect available Stow modules
ls -d */

# 3. Symlink all configurations to $HOME
stow --target=$HOME hyprland nvim fish git ghostty tmux mise

# 4. Verify Neovim plugins and runtime tools
nvim --headless "+Lazy! sync" +qa
mise install
```

---

## 🔄 Automated Workstation Sync

Configurations are tracked with automated branch hygiene. Sensitive tokens, SSH private keys, and local environment secrets are strictly segregated into untracked `.env.local` files managed via private password stores.

---

## 👤 Author

- **Iker Nistal Fernandez** ([@Niistal](https://github.com/Niistal))
