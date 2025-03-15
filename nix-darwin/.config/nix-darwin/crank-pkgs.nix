{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    direnv
  ];
  homebrew.casks = [
    "adobe-acrobat-reader"
  ];
}
