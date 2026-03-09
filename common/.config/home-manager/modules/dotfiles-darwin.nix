{lib, ...}: let
  helpers = import ./helpers.nix {inherit lib;};
  darwinRoot = ../../../../macos;
in {
  home.file = helpers.mkDiscoveredDirLinks darwinRoot [
    ".config"
  ];

  xdg.configFile =
    helpers.mkDiscoveredDirLinks (darwinRoot + "/.config") [
      "git"
    ]
    // helpers.mkPrefixedFileLinks "git" (darwinRoot + "/.config/git") [
    "config-credential"
  ];
}
