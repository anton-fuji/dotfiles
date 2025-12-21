{ pkgs, username, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };

  system.primaryUser = username;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  system.stateVersion = 5;

  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      tilesize = 45;
      show-process-indicators = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
      NewWindowTarget = "Home";
    };

    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleInterfaceStyle = "Dark";
      # Keyboard
      InitialKeyRepeat = 15;
      KeyRepeat = 2;

      # Trackpad
      "com.apple.trackpad.scaling" = 2.0;
      NSNavPanelExpandedStateForSaveMode = true;
      AppleShowScrollBars = "Always";
    };

    # Trackpad settings
    trackpad = {
      Clicking = false;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
}
