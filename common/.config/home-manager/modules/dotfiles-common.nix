{lib, dotfilesRoot, ...}: let
  helpers = import ./helpers.nix {
    inherit lib dotfilesRoot;
  };
  commonRoot = dotfilesRoot + "/common";
in {
  home.file =
    helpers.mkDiscoveredFileLinks commonRoot []
    // helpers.mkDiscoveredDirLinks commonRoot [
      ".config"
    ]
    // {
      ".config/home-manager" = {
        source = helpers.cleanSource (dotfilesRoot + "/common/.config/home-manager");
        recursive = true;
        force = true;
      };
    };

  xdg.configFile = helpers.mkDiscoveredDirLinks (commonRoot + "/.config") [
    "home-manager"
  ];
}
