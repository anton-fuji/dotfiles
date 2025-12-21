{ pkgs, lib, ... }:

let 
  lazygitConfigYaml = builtins.readFile ./config.yml;
  
  lazygitConfigWithDeltaPath =
    builtins.replaceStrings [ "pager: delta " ] [ "pager: ${lib.getExe pkgs.delta}" ]
      lazygitConfigYaml;
in
{
  programs.lazygit = {
    enable = true;
  };

  xdg.configFile."lazygit/config.yml" = {
    text = lazygitConfigWithDeltaPath;
  };
}
