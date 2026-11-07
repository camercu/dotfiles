{
  config,
  lib,
  pkgs,
  ...
}: let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in {
  options.dotfiles.systemGhostty = lib.mkEnableOption
    "Ghostty from a system package instead of nix (its terminfo still comes from nix)";

  config.home.packages =
    with pkgs;
      [
        bat
        fd
        fzf
        git
        lazygit
        neovim
        ripgrep
        tmux
        tree-sitter
        zoxide
      ]
      ++ lib.optionals isDarwin [
        pngpaste
      ]
      ++ lib.optionals (isLinux && !config.dotfiles.systemGhostty) [ghostty]
      ++ lib.optionals isLinux [
        # Listed on its own so hosts reached over ssh keep xterm-ghostty even
        # without the GUI app; env/terminfo.sh puts it on TERMINFO_DIRS.
        ghostty.terminfo
        wl-clipboard
      ];

  # Standalone Home Manager on a non-NixOS distro: nix GUI apps (ghostty)
  # need the host GPU drivers linked into /run/opengl-driver. Activation
  # prints the one-time `sudo non-nixos-gpu-setup` step that does this.
  config.targets.genericLinux.enable = isLinux;
}
