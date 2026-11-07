{lib, hostsFile ? ../hosts.tsv}: let
  readHostLines =
    builtins.filter (line:
      line != ""
      && !(lib.hasPrefix "#" line)) (lib.splitString "\n" (builtins.readFile hostsFile));

  parseModulePaths = rawPaths:
    builtins.filter (path: path != "") (lib.splitString "," rawPaths);

  # Rejects a bad row while evaluating, so a hosts.tsv typo breaks the flake
  # instead of building a home for the wrong user or path.
  parseHost = line: let
    parts = lib.splitString "|" line;
    field = builtins.elemAt parts;
    configName = field 0;
    username = field 2;
    displayName = field 5;
    primaryUser = field 6;
    # user@host names one user on a host that others share; see README.
    userPart = builtins.match "([^@]*)@.*" configName;
  in
    assert lib.assertMsg (builtins.length parts == 8)
    "hosts.tsv: row '${line}' needs 8 '|'-separated fields, has ${toString (builtins.length parts)}";
    assert lib.assertMsg (builtins.match "([a-z0-9_-]+@)?[a-z0-9_-]+" configName != null)
    "hosts.tsv: config name '${configName}' must be lowercase letters, digits, _ or -, optionally as user@host";
    assert lib.assertMsg (userPart == null || builtins.head userPart == username)
    "hosts.tsv: config '${configName}' names user '${builtins.head userPart}' but its username column is '${username}'"; {
      inherit configName username;
      system = field 1;
      homeDirectory = field 3;
      displayName =
        if displayName != ""
        then displayName
        else configName;
      primaryUser =
        if primaryUser != ""
        then primaryUser
        else null;
      extraModules = parseModulePaths (field 7);
    };

  hosts = map parseHost readHostLines;
in {
  inherit hosts;
  linuxHosts = builtins.filter (host: lib.hasSuffix "-linux" host.system) hosts;
  darwinHosts = builtins.filter (host: lib.hasSuffix "-darwin" host.system) hosts;
}
