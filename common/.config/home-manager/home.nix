{lib, pkgs, ...}: {
  imports = [
    ./modules/packages.nix
    ./modules/xfce.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
