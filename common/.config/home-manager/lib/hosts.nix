{lib, hostsFile ? ../hosts.tsv}: let
  normalizeName = value:
    lib.concatStrings (
      builtins.filter (char:
        builtins.match "[a-z0-9_-]" char != null) (lib.stringToCharacters (lib.toLower value)));

  readHostLines =
    builtins.filter (line:
      line != ""
      && !(lib.hasPrefix "#" line)) (lib.splitString "\n" (builtins.readFile hostsFile));

  parseAliases = rawAliases:
    builtins.filter (aliasName: aliasName != "") (map normalizeName (lib.splitString "," rawAliases));

  parseModulePaths = rawPaths:
    builtins.filter (path: path != "") (lib.splitString "," rawPaths);

  parseHost = line: let
    parts = lib.splitString "|" line;
    displayName = builtins.elemAt parts 5;
    primaryUser = builtins.elemAt parts 6;
  in {
    configName = normalizeName (builtins.elemAt parts 0);
    system = builtins.elemAt parts 1;
    username = builtins.elemAt parts 2;
    homeDirectory = builtins.elemAt parts 3;
    aliases = parseAliases (builtins.elemAt parts 4);
    displayName =
      if displayName != ""
      then displayName
      else builtins.elemAt parts 0;
    primaryUser =
      if primaryUser != ""
      then primaryUser
      else null;
    darwinExtraModules = parseModulePaths (builtins.elemAt parts 7);
  };

  hosts = map parseHost readHostLines;
in {
  inherit hosts normalizeName;

  byName =
    builtins.listToAttrs (map (host: {
        name = host.configName;
        value = host;
      })
      hosts);

  linuxHosts = builtins.filter (host: lib.hasSuffix "-linux" host.system) hosts;
  darwinHosts = builtins.filter (host: lib.hasSuffix "-darwin" host.system) hosts;
}
