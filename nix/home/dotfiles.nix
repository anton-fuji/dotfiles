{ pkgs, lib, config, ... }:

let
  homeDir = config.home.homeDirectory;
  dotfilesDir = "${homeDir}/.config";

  helpers = import ./lib/helpers.nix { inherit lib; };
in
{
  home.activation.linkDotfiles = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ${helpers.activation.mkLinkForce}

    # WezTerm
    link_force "${dotfilesDir}/wezterm" "${configHome}/wezterm"

    # Neovim
    link_force "${dotfilesDir}/nvim" "${configHome}/nvim"

    # Yazi
    link_force "${dotfilesDir}/yazi" "${configHome}/yazi"

    # Zellij
    link_force "${dotfilesDir}/zellij" "${configHome}/zellij"

    link_force "${dotfilesDir}/tig" "${configHome}/tig"

    # eza
    link_force "${dotfilesDir}/eza" "${configHome}/eza"

    # Starship
    link_force "${dotfilesDir}/starship.toml" "${configHome}/starship.toml"

    # Zsh
    # link_force "${dotfilesDir}/zsh/.zshrc" "${homeDir}/.zshrc"
  '';
}
