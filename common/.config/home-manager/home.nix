{lib, pkgs, ...}: {
  imports = [
    ./modules/packages.nix
    ./modules/dotfiles-common.nix
    ./modules/dotfiles-darwin.nix
    ./modules/dotfiles-linux.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
