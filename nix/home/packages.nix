{ pkgs, ... }:

let
  czg = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "czg";
    version = "1.13.1";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/czg/-/czg-${version}.tgz";
      hash = "sha256-stnVZz8gNXIYkiB48FffwK1X0TZ8tCJKzC7OURqGBI0=";
    };

    sourceRoot = "package";
    dontConfigure = true;
    dontBuild = true;
    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      mkdir -p "$out/lib/node_modules/czg" "$out/bin"
      cp -R . "$out/lib/node_modules/czg/"
      makeWrapper "${pkgs.nodejs}/bin/node" "$out/bin/czg" \
        --add-flags "$out/lib/node_modules/czg/bin/index.js"
      ln -s "$out/bin/czg" "$out/bin/git-czg"
    '';
  };
in
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
  ] ++ [ czg ];
}
