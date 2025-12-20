{
  description = "Fuji's home-manager configuration";

  inputs = {
    nixpkgs = {
      url = "github:Nixos/nixpkgs/nixpkgs-unstable";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    neovim-nightly-overlay,
    }:
    let
      username = "fujimotoikki";
      hostname  = "fujimotoikkinoMacBook-Air-2";
      system = "aarch64-darwin";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        neovim-nightly-overlay.overlays.default
        ];
      };
    in
    {
    # macOS configuration
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit username pkgs; };
      modules = [
        ./nix/darwin/configuration.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./nix/home/home.nix;
          home-manager.extraSpecialArgs = { inherit username; };
        }
      ];
    };
  };
}
