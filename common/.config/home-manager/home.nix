{ pkgs, lib, ... }:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  # Define username and home directory to manage
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME"

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Nix packages to install for the user.
  home.packages = with pkgs; ([
    # Common packages
    fd
    fzf
    git
    lazygit
    neovim
    ripgrep
    stow
    tmux
    tree-sitter
  ]

  ++ lib.optionals (isDarwin) [
      # MacOS only packages
    ]

  ++ lib.optionals (isLinux) [
      # Linux only packages
    ]
  # Install Nerd Fonts
  ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts)  );

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
