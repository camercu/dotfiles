{lib, dotfilesRoot}: let
  ignoreDir = dotfilesRoot + "/lib/dotfiles-ignore";
  readPatterns = file:
    builtins.filter (line:
      line != ""
      && !lib.hasPrefix "#" line) (lib.splitString "\n" (builtins.readFile file));

  exactNames =
    readPatterns (ignoreDir + "/file-names.txt")
    ++ readPatterns (ignoreDir + "/dir-names.txt");
  prefixes = readPatterns (ignoreDir + "/prefixes.txt");
  suffixes = readPatterns (ignoreDir + "/suffixes.txt");
  pathSegments = readPatterns (ignoreDir + "/path-segments.txt");

  shouldIgnore = rel: base:
    lib.any (name: base == name) exactNames
    || lib.any (prefix: lib.hasPrefix prefix base) prefixes
    || lib.any (suffix: lib.hasSuffix suffix base) suffixes
    || lib.any (segment:
      rel == segment
      || lib.hasInfix "/${segment}/" rel
      || lib.hasSuffix "/${segment}" rel) pathSegments;

  cleanSource = root:
    builtins.path {
      path = root;
      name = builtins.unsafeDiscardStringContext (builtins.baseNameOf (toString root));
      filter = path: _type: let
        rootStr = toString root;
        pathStr = toString path;
        rel =
          if pathStr == rootStr
          then ""
          else lib.removePrefix "${rootStr}/" pathStr;
        base = builtins.baseNameOf pathStr;
      in
        !(shouldIgnore rel base);
    };

  mkLinksWithPrefix = prefix: root: names: recursive:
    builtins.listToAttrs (map (name: {
        name =
          if prefix == ""
          then name
          else "${prefix}/${name}";
        value =
          {
            source = cleanSource (root + "/${name}");
            force = true;
          }
          // lib.optionalAttrs recursive {inherit recursive;};
      })
      names);

  topLevelNamesByType = root: expectedType: exclude:
    lib.attrNames (lib.filterAttrs (name: entryType:
      entryType == expectedType
      && !(builtins.elem name exclude)
      && !(shouldIgnore name name)) (builtins.readDir root));
in {
  inherit cleanSource;
  mkFileLinks = root: names: mkLinksWithPrefix "" root names false;
  mkDirLinks = root: names: mkLinksWithPrefix "" root names true;
  mkPrefixedFileLinks = prefix: root: names: mkLinksWithPrefix prefix root names false;
  mkPrefixedDirLinks = prefix: root: names: mkLinksWithPrefix prefix root names true;
  mkDiscoveredFileLinks = root: exclude: mkLinksWithPrefix "" root (topLevelNamesByType root "regular" exclude) false;
  mkDiscoveredDirLinks = root: exclude: mkLinksWithPrefix "" root (topLevelNamesByType root "directory" exclude) true;
  mkDiscoveredPrefixedFileLinks = prefix: root: exclude: mkLinksWithPrefix prefix root (topLevelNamesByType root "regular" exclude) false;
  mkDiscoveredPrefixedDirLinks = prefix: root: exclude: mkLinksWithPrefix prefix root (topLevelNamesByType root "directory" exclude) true;
}
