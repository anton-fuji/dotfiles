{ pkgs, lib, username, config, ... }:

let
  homedir = "/Users/${username}";
in
{
  imports = [
    ./packages.nix

    ./programs

    (import ./dotfiles.nix {
      inherit pkgs lib config;
    })
  ];

  home = {
    username = username;
    homeDirectory = homedir;
    stateVersion = "24.11";
  };

  xdg.enable = true;

  programs.home-manager.enable = true;
}
