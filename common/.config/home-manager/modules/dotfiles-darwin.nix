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
    "Library/Application Support/org.dystroy.bacon/prefs.toml".force = true;
  };

  xdg.configFile =
    helpers.mkDiscoveredDirLinks (darwinRoot + "/.config") [
      "git"
    ]
    // helpers.mkPrefixedFileLinks "git" (darwinRoot + "/.config/git") [
    "config-credential"
  ];
}
