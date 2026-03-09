{lib, pkgs, dotfilesRoot, ...}: let
  helpers = import ./helpers.nix {
    inherit lib dotfilesRoot;
  };
  darwinRoot = dotfilesRoot + "/macos";
in
  lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  home.file = helpers.mkDiscoveredDirLinks darwinRoot [
    ".config"
  ] // {
    "Library" = {
      source = helpers.cleanSource (darwinRoot + "/Library");
      recursive = true;
      force = true;
    };
  };

  xdg.configFile =
    helpers.mkDiscoveredDirLinks (darwinRoot + "/.config") [
      "git"
    ]
    // helpers.mkPrefixedFileLinks "git" (darwinRoot + "/.config/git") [
    "config-credential"
  ];
}
