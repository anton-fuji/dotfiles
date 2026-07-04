{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # dev tools
    neovim
    git
    gh
    ghq
    just
    lazygit
    devenv
    nil
    nixpkgs-fmt

    starship
    zsh-autosuggestions

    eza
    bat
    fd
    fish
    ripgrep
    fzf
    peco
    zoxide
    yazi
    tig

    # terminal tools
    zellij

    # runtime
    bun
    go
    google-cloud-sdk
    mise
    nodejs
    rustup
    uv
    zig

    # DevOps
    terraform
    terraform-ls
    lazydocker
    act
    direnv

    delta
    gcc14
    gh-dash
    posting
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
