{
  description = "Crank's Home Manager configuration";
  # adapted from https://github.com/crasm/dead-simple-home-manager

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  }: {
    homeConfigurations = {
      # Legacy Intel-based MacOS machines
      "cameron@Camerons-MacBook-Pro.local" = home-manager.lib.homeManagerConfiguration {
        modules = [
          (import ./home.nix)
          {
            config.home = {
              username = builtins.getEnv "USER";
              homeDirectory = builtins.getEnv "HOME";
            };
          }
        ];
        pkgs = import nixpkgs {
          system = "x86_64-darwin";
        };
      };

      # Apple Silicon Machines
      "TheRoci" = home-manager.lib.homeManagerConfiguration {
        modules = [
          (import ./home.nix)
          {
            config.home = {
              username = builtins.getEnv "USER";
              homeDirectory = builtins.getEnv "HOME";
            };
          }
        ];
        pkgs = import nixpkgs rec {
          system = "aarch64-darwin";
        };
      };

      # Linux Machines
      "cr4nk@somnambulist" = home-manager.lib.homeManagerConfiguration {
        modules = [
          (import ./home.nix)
          {
            config.home = {
              username = builtins.getEnv "USER";
              homeDirectory = builtins.getEnv "HOME";
            };
          }
        ];
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
    };
  };
}
