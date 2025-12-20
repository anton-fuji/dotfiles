{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # dev tools
    neovim
    git
    gh
    ghq
    tig
    lazygit

    starship
    zsh-autosuggestions

    eza
    bat
    fd
    ripgrep
    fzf
    peco
    zoxide
    yazi

    # terminal tools
    wezterm
    zellij

    # runtime
    go
    nodejs
    rustup

    # DevOps
    terraform
    terraform-ls
    lazydocker
    act

    delta
    tree-sitter
    htop
    btop
    httpie
    wget
    jq

    # Other
    hadolint
    typos
    gibo
    nkf
  ];
}
