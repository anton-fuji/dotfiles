<div align="center">

# Dotfiles

**A macOS development environment tuned around Nix, Neovim, WezTerm, and fast terminal workflows.**

<p>
  <img src="https://img.shields.io/badge/Nix-0f172a?style=for-the-badge&logo=nixos&logoColor=7EBAE4" alt="Nix">
  <img src="https://img.shields.io/badge/Neovim-0f191f?style=for-the-badge&logo=neovim&logoColor=57A143" alt="Neovim">
  <img src="https://img.shields.io/badge/WezTerm-111827?style=for-the-badge&logo=wezterm&logoColor=white" alt="WezTerm">
  <img src="https://img.shields.io/badge/Zellij-101820?style=for-the-badge&logo=windowsterminal&logoColor=white" alt="Zellij">
</p>

<img src="./img/nvim.png" alt="Neovim setup screenshot" width="900">

</div>

## Overview

This repository is the source of truth for my `~/.config`.

It is built for a keyboard-first macOS setup: reproducible packages through Nix, a Lua-based Neovim IDE, a highly customized terminal stack, and small CLI tools wired together for day-to-day engineering work.

## Stack

| Area | Tools |
| --- | --- |
| System | Nix, nix-darwin, Home Manager |
| Editor | Neovim nightly, Lua, LSP, Treesitter, Telescope |
| Terminal | WezTerm, Zellij, Starship, Fish |
| UI | SketchyBar, Fastfetch |
| CLI | GitHub CLI, lazygit, ghq, ripgrep, fd, fzf, eza, bat, zoxide |
| Files | Yazi, htop, btop |
| Dev | Go, Node.js, Rust, Terraform, Docker-adjacent tooling |

## Highlights

- `flake.nix` defines the macOS/Home Manager entrypoint.
- `nvim/` contains the editor configuration, split into options, keybinds, extensions, LSP, and templates.
- `wezterm/` keeps terminal appearance, keymaps, transparency, and background behavior isolated.
- `zellij/` provides modal terminal multiplexing with explicit pane/tab workflows.
- `sketchybar/` drives the macOS status bar with Lua modules and helper binaries.
- `yazi/` adds a fast terminal file manager with git-aware fetchers.

## Layout

```text
.
├── flake.nix
├── justfile
├── nix/
│   ├── darwin/
│   └── home/
├── nvim/
├── wezterm/
├── zellij/
├── sketchybar/
├── yazi/
├── fish/
├── btop/
├── fastfetch/
└── img/
```

## Bootstrap

This repo is intended to live directly at `~/.config`.

1. Install Nix with flakes enabled.
2. Install nix-darwin.
3. Clone this repository to `~/.config`.
4. Apply the host configuration.

```sh
cd ~/.config
just switch
```

Without `just`:

```sh
cd ~/.config
darwin-rebuild switch --flake .#fujimotoikkinoMacBook-Air-2
```

## Commands

```sh
just fmt      # format Nix files
just check    # evaluate flake outputs without building
just dry-run  # show what Nix would build/fetch
just build    # build the darwin system closure
just switch   # apply the darwin configuration
just update   # update flake.lock
```

## Notes

This is a personal environment, not a generic starter kit. Secrets, machine-local state, caches, and app-generated databases are intentionally excluded from git.

The goal is simple: keep the actual working config under version control, without copying files back and forth.
