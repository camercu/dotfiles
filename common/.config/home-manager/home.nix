{lib, pkgs, ...}: {
  imports = [
    ./modules/packages.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
