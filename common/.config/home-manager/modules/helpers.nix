{lib}: let
  shouldIgnore = rel: base:
    base == ".DS_Store"
    || base == ".gitignore"
    || base == ".nvimlog"
    || base == ".zcompdump"
    || rel == "Crash Reports"
    || lib.hasInfix "/Crash Reports/" rel;

  cleanSource = root:
    builtins.path {
      path = root;
      name = builtins.baseNameOf (toString root);
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
          }
          // lib.optionalAttrs recursive {inherit recursive;};
      })
      names);

  topLevelNamesByType = root: expectedType: exclude:
    lib.attrNames (lib.filterAttrs (name: entryType:
      entryType == expectedType && !(builtins.elem name exclude)) (builtins.readDir root));
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
