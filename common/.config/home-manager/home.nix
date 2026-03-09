{lib, pkgs, ...}: {
  imports =
    [
      ./modules/packages.nix
      ./modules/dotfiles-common.nix
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      ./modules/dotfiles-darwin.nix
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      ./modules/dotfiles-linux.nix
    ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
