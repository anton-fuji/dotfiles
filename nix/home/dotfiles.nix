{ pkgs, lib, config, ... }:

{
  home.sessionVariables = {
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
  };
}
