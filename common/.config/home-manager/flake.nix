{
  description = "Linux standalone Home Manager configuration";

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
    lib = nixpkgs.lib;
    hostData = import ./lib/hosts.nix {inherit lib;};
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
    homeConfigurations =
      builtins.listToAttrs (map (host: {
          name = host.configName;
          value = mkHome {
            inherit (host) system username;
            homeDirectory =
              if host.homeDirectory == ""
              then null
              else host.homeDirectory;
          };
        })
        hostData.linuxHosts);
  };
}
