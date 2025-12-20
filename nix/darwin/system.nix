{ pkgs, username, ...}

{
  environment.systemPackages = with pkg; [
    vim
    git
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };

  services.nix-daemon.enable = true;

  users.users.${username} = {
    name = username;
    home = "Users/${username}";
  };

  system = {
    stateVersion = 5;

    default = {
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
        NewWindowTarget = "PfHm";
       };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleInterfaceStyle = "Dark";

        # Keybord
        InitialKeyRepeat = 15;
        KeyRepeat = 2;

       #Tracjpad
       "com.apple.trackpad.scaling" = 2.0;

        NSNavPanelExpandedStateForSaveMode = true;

        AppleShowScrollBars = "Always";
      };

       # Trackpad settings
       trackpad = {
          Clicking = false; # Tap to click disabled
          TrackpadRightClick = true; # Two-finger secondary click
          TrackpadThreeFingerDrag = false; # Disable three-finger drag
        };
     };
   }
}
