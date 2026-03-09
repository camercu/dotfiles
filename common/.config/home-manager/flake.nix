{
  description = "Cross-platform Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  }: let
    mkHome = {
      system,
      username,
      homeDirectory ? null,
      extraModules ? [],
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        modules =
          [
            ./home.nix
            {
              home.username = username;
              home.homeDirectory =
                if homeDirectory != null
                then homeDirectory
                else if builtins.match ".*-darwin" system != null
                then "/Users/${username}"
                else "/home/${username}";
            }
          ]
          ++ extraModules;
      };
  in {
    homeConfigurations = {
      roci = mkHome {
        system = "aarch64-darwin";
        username = "cameron";
      };

      theark = mkHome {
        system = "aarch64-darwin";
        username = "kadmin";
      };

      jessieslaptop = mkHome {
        system = "aarch64-darwin";
        username = "jadmin";
      };

      tachi = mkHome {
        system = "x86_64-darwin";
        username = "cameron";
      };

      somnambulist = mkHome {
        system = "x86_64-linux";
        username = "cr4nk";
      };
    };
  };
}
