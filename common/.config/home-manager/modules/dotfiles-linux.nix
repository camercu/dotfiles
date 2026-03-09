{lib, pkgs, dotfilesRoot, ...}: let
  helpers = import ./helpers.nix {
    inherit lib dotfilesRoot;
  };
  linuxRoot = dotfilesRoot + "/linux";
in
  lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.file =
    helpers.mkDiscoveredFileLinks linuxRoot []
    // helpers.mkDiscoveredDirLinks linuxRoot [
      ".config"
    ];

  xdg.configFile = helpers.mkDiscoveredDirLinks (linuxRoot + "/.config") [
    "git"
  ]
  // helpers.mkPrefixedFileLinks "git" (linuxRoot + "/.config/git") [
    "config-credential"
  ];
}
