{
  description = "Compatibility wrapper for the root dotfiles flake";

  inputs.dotfiles.url = "path:../../..";

  outputs = {dotfiles, ...}: {
    inherit (dotfiles) homeConfigurations;
  };
}
