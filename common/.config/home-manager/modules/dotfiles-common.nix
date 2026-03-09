{lib, ...}: let
  helpers = import ./helpers.nix {inherit lib;};
  commonRoot = ../../..;
in {
  home.file =
    helpers.mkDiscoveredFileLinks commonRoot [
      ".DS_Store"
    ]
    // helpers.mkDiscoveredDirLinks commonRoot [
      ".config"
    ]
    // {
      ".config/home-manager" = {
        source = helpers.cleanSource ../.;
        recursive = true;
      };
    };

  xdg.configFile = helpers.mkDiscoveredDirLinks (commonRoot + "/.config") [
    "home-manager"
  ];
}
