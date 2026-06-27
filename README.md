## dotfiles

[![FOSSA Status](https://app.fossa.com/api/projects/custom%2B51440%2Fgit%40github.com%3Aanton-fuji%2Fdotfiles.git.svg?type=small)](https://app.fossa.com/projects/custom%2B51440%2Fgit%40github.com%3Aanton-fuji%2Fdotfiles.git?ref=badge_small)
![WezTerm](https://img.shields.io/badge/WezTerm-000000?style=flat&logo=wezterm&logoColor=8A2BE2)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=flat&logo=neovim&logoColor=ffffff)
![Zellij](https://img.shields.io/badge/Zellij-0E0E0E?style=flat&logo=gnu-bash&logoColor=white)

Personal dotfiles for a macOS development environment. The repository mainly contains terminal, editor, shell, and CLI tool configuration, with Nix/Home Manager files for managing packages and macOS defaults.

### Included

- `wezterm/` - WezTerm terminal configuration
- `nvim/` - Neovim configuration
- `zellij/` - Zellij configuration and layouts
- `yazi/` - Yazi file manager configuration and theme
- `sketchybar/` - SketchyBar configuration
- `git/` - Git config examples and aliases
- `nix/` and `flake.nix` - nix-darwin/Home Manager configuration
- `starship.toml`, `eza/`, `fastfetch/`, `hunk/` - CLI tool configuration

### Manual Setup

Clone this repository and link the configuration directories you want to use into `~/.config`.

```bash
git clone git@github.com:anton-fuji/dotfiles.git ~/MyDev/dotfiles
mkdir -p ~/.config
ln -sfn ~/MyDev/dotfiles/wezterm ~/.config/wezterm
ln -sfn ~/MyDev/dotfiles/nvim ~/.config/nvim
ln -sfn ~/MyDev/dotfiles/zellij ~/.config/zellij
ln -sfn ~/MyDev/dotfiles/yazi ~/.config/yazi
ln -sfn ~/MyDev/dotfiles/starship.toml ~/.config/starship.toml
```

Git's local config is intentionally kept out of the repository. Use the example file as a starting point when needed.

```bash
cp git/gitconfig.local.symlink.example git/gitconfig.local.symlink
```

### Nix Setup

This repository also includes a Nix flake for macOS with nix-darwin and Home Manager. It is tailored to one machine, so review the hard-coded values and local import paths in `flake.nix` before applying it elsewhere.

```bash
nix flake check
darwin-rebuild switch --flake .#fujimotoikkinoMacBook-Air-2
```

### WezTerm Preview

![WezTerm and Neovim overview](img/nvim-wez.png)
