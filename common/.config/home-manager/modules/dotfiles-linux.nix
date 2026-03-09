{lib, ...}: let
  helpers = import ./helpers.nix {inherit lib;};
  linuxRoot = ../../../../linux;
in {
  home.file =
    helpers.mkDiscoveredFileLinks linuxRoot [
      ".DS_Store"
    ]
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
