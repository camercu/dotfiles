{lib, pkgs, ...}: let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in {
  home.packages =
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
      ++ lib.optionals isLinux [
        ghostty
        wl-clipboard
      ];

  # Standalone Home Manager on a non-NixOS distro: nix GUI apps (ghostty)
  # need the host GPU drivers linked into /run/opengl-driver. Activation
  # prints the one-time `sudo non-nixos-gpu-setup` step that does this.
  targets.genericLinux.enable = isLinux;
}
