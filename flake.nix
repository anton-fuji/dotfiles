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

  outputs =
    inputs@{ self
    , nixpkgs
    , nix-darwin
    , home-manager
    , neovim-nightly-overlay
    ,
    }:
    let
      # ユーザー名はリポジトリに書かず、実行時の環境変数から読む(要 --impure)。
      # root 権限で darwin-rebuild を実行すると USER が root になるため SUDO_USER を優先する。
      username =
        let
          sudoUser = builtins.getEnv "SUDO_USER";
          user = builtins.getEnv "USER";
        in
        if sudoUser != "" then sudoUser
        else if user != "" && user != "root" then user
        else throw "username を取得できません。--impure を付けて実行してください。";
      hostname = "macbook";
      system = "aarch64-darwin";
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit username inputs; };
        modules = [
          ./nix/darwin/system.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.users.${username} = import ./nix/home/default.nix;
            home-manager.extraSpecialArgs = { inherit username; };
          }
        ];
      };
    };
}
