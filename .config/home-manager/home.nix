{ pkgs, lib, ... }:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  unsupported = builtins.abort "Unsupported platform";
  username = if isLinux then "cr4nk" else if isDarwin then "cameron" else unsupported;
in
{
  # Define username and home directory to manage
  home.username = username;
  home.homeDirectory = if isLinux then "/home/${username}" else if isDarwin then "/Users/${username}" else unsupported;

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
    nerdfonts
    ripgrep
    stow
    tmux
  ]

  # ++ lib.optional (isDarwin) [
  #     # MacOS only packages
  #   ]
  #
  # ++ lib.optional (isLinux) [
  #     # Linux only packages
  #   ]
  );

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
